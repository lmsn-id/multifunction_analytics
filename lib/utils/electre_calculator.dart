import 'dart:math';

class ElectreCalculator {
  static Map<String, dynamic> calculate(
    List<List<double>> matrix,
    List<double> weights,
    List<bool> isBenefits,
    List<String> alternativeNames,
  ) {
    if (matrix.isEmpty) {
      return {'rankings': []};
    }

    final int n = matrix.length;
    final int m = matrix[0].length;

    if (weights.length != m) {
      throw Exception(
        'Jumlah bobot (${weights.length}) harus sama dengan jumlah kriteria ($m)',
      );
    }

    if (isBenefits.length != m) {
      throw Exception(
        'Jumlah tipe kriteria (${isBenefits.length}) harus sama dengan jumlah kriteria ($m)',
      );
    }

    if (weights.every((e) => e == 0)) {
      throw Exception('Bobot tidak boleh semuanya nol');
    }

    // =====================================================
    // GUNAKAN DEFAULT NAMES JIKA KOSONG
    // =====================================================
    final List<String> finalNames = List.generate(
      n,
      (i) => alternativeNames[i].trim().isEmpty
          ? 'Alternatif ${i + 1}'
          : alternativeNames[i],
    );

    // =====================================================
    // NORMALISASI BOBOT
    // =====================================================

    final double totalWeight = weights.fold(0.0, (a, b) => a + b);

    final List<double> normalizedWeights = weights
        .map((e) => e / totalWeight)
        .toList();

    // =====================================================
    // NORMALISASI
    // =====================================================

    final normalizedMatrix = _normalizeMatrix(matrix);

    // =====================================================
    // WEIGHTED MATRIX
    // =====================================================

    final weightedMatrix = _weightedMatrix(normalizedMatrix, normalizedWeights);

    // =====================================================
    // CONCORDANCE
    // =====================================================

    final concordanceMatrix = _concordanceIndex(
      normalizedMatrix,
      normalizedWeights,
      isBenefits,
    );

    // =====================================================
    // DISCORDANCE
    // =====================================================

    final discordanceMatrix = _discordanceIndex(weightedMatrix, isBenefits);

    // =====================================================
    // THRESHOLD
    // =====================================================

    final concordanceThreshold = _averageThreshold(concordanceMatrix);

    final discordanceThreshold = _averageThreshold(discordanceMatrix);

    // =====================================================
    // DOMINANCE MATRICES
    // =====================================================

    final concordanceDominance = _concordanceDominance(
      concordanceMatrix,
      concordanceThreshold,
    );

    final discordanceDominance = _discordanceDominance(
      discordanceMatrix,
      discordanceThreshold,
    );

    // =====================================================
    // AGGREGATE
    // =====================================================

    final aggregateDominance = _aggregateDominance(
      concordanceDominance,
      discordanceDominance,
    );

    // =====================================================
    // RANKING
    // =====================================================

    final rankings = _calculateRanking(aggregateDominance, finalNames);

    return {
      'rankings': rankings,
      'normalized_weights': normalizedWeights,
      'normalized_matrix': normalizedMatrix,
      'weighted_matrix': weightedMatrix,
      'concordance_matrix': concordanceMatrix,
      'discordance_matrix': discordanceMatrix,
      'concordance_dominance': concordanceDominance,
      'discordance_dominance': discordanceDominance,
      'aggregate_dominance': aggregateDominance,
      'thresholds': {
        'concordance': concordanceThreshold,
        'discordance': discordanceThreshold,
      },
      'summary': {
        'Jumlah Alternatif': n,
        'Jumlah Kriteria': m,
        'Threshold Concordance': concordanceThreshold.toStringAsFixed(4),
        'Threshold Discordance': discordanceThreshold.toStringAsFixed(4),
        'Alternatif Terbaik': rankings.isNotEmpty
            ? rankings[0]['alternative']
            : '-',
        'Skor Terbaik': rankings.isNotEmpty ? rankings[0]['score'] : '-',
      },
    };
  }

  // =====================================================
  // NORMALISASI VECTOR
  // =====================================================

  static List<List<double>> _normalizeMatrix(List<List<double>> matrix) {
    final int n = matrix.length;
    final int m = matrix[0].length;

    final normalized = List.generate(n, (_) => List.filled(m, 0.0));

    for (int j = 0; j < m; j++) {
      double divisor = 0;

      for (int i = 0; i < n; i++) {
        divisor += pow(matrix[i][j], 2);
      }

      divisor = sqrt(divisor);

      for (int i = 0; i < n; i++) {
        normalized[i][j] = divisor == 0 ? 0 : matrix[i][j] / divisor;
      }
    }

    return normalized;
  }

  // =====================================================
  // WEIGHTED MATRIX
  // =====================================================

  static List<List<double>> _weightedMatrix(
    List<List<double>> normalized,
    List<double> weights,
  ) {
    final int n = normalized.length;
    final int m = normalized[0].length;

    return List.generate(
      n,
      (i) => List.generate(m, (j) => normalized[i][j] * weights[j]),
    );
  }

  // =====================================================
  // CONCORDANCE
  // =====================================================

  static List<List<double>> _concordanceIndex(
    List<List<double>> normalized,
    List<double> weights,
    List<bool> isBenefits,
  ) {
    final int n = normalized.length;
    final int m = normalized[0].length;

    final result = List.generate(n, (_) => List.filled(n, 0.0));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) continue;

        double score = 0;

        for (int k = 0; k < m; k++) {
          bool support;

          if (isBenefits[k]) {
            support = normalized[i][k] >= normalized[j][k];
          } else {
            support = normalized[i][k] <= normalized[j][k];
          }

          if (support) {
            score += weights[k];
          }
        }

        result[i][j] = score;
      }
    }

    return result;
  }

  // =====================================================
  // DISCORDANCE
  // =====================================================

  static List<List<double>> _discordanceIndex(
    List<List<double>> weighted,
    List<bool> isBenefits,
  ) {
    final int n = weighted.length;
    final int m = weighted[0].length;

    final result = List.generate(n, (_) => List.filled(n, 0.0));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) continue;

        double numerator = 0;
        double denominator = 0;

        for (int k = 0; k < m; k++) {
          final diff = (weighted[i][k] - weighted[j][k]).abs();

          denominator = max(denominator, diff);

          bool discordant;

          if (isBenefits[k]) {
            discordant = weighted[i][k] < weighted[j][k];
          } else {
            discordant = weighted[i][k] > weighted[j][k];
          }

          if (discordant) {
            numerator = max(numerator, diff);
          }
        }

        result[i][j] = denominator == 0 ? 0 : numerator / denominator;
      }
    }

    return result;
  }

  // =====================================================
  // THRESHOLD
  // =====================================================

  static double _averageThreshold(List<List<double>> matrix) {
    double sum = 0;
    int count = 0;

    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix.length; j++) {
        if (i == j) continue;

        sum += matrix[i][j];
        count++;
      }
    }

    return count == 0 ? 0 : sum / count;
  }

  // =====================================================
  // CONCORDANCE DOMINANCE
  // =====================================================

  static List<List<int>> _concordanceDominance(
    List<List<double>> matrix,
    double threshold,
  ) {
    final int n = matrix.length;

    return List.generate(
      n,
      (i) =>
          List.generate(n, (j) => i != j && matrix[i][j] >= threshold ? 1 : 0),
    );
  }

  // =====================================================
  // DISCORDANCE DOMINANCE
  // =====================================================

  static List<List<int>> _discordanceDominance(
    List<List<double>> matrix,
    double threshold,
  ) {
    final int n = matrix.length;

    return List.generate(
      n,
      (i) =>
          List.generate(n, (j) => i != j && matrix[i][j] <= threshold ? 1 : 0),
    );
  }

  // =====================================================
  // AGGREGATE
  // =====================================================

  static List<List<int>> _aggregateDominance(
    List<List<int>> c,
    List<List<int>> d,
  ) {
    final int n = c.length;

    return List.generate(n, (i) => List.generate(n, (j) => c[i][j] * d[i][j]));
  }

  static List<Map<String, dynamic>> _calculateRanking(
    List<List<int>> aggregate,
    List<String> names,
  ) {
    final int n = aggregate.length;

    final rankings = <Map<String, dynamic>>[];

    for (int i = 0; i < n; i++) {
      int outgoing = 0;
      int incoming = 0;

      for (int j = 0; j < n; j++) {
        outgoing += aggregate[i][j];
        incoming += aggregate[j][i];
      }

      rankings.add({
        'alternative': names[i],
        'outgoing': outgoing,
        'incoming': incoming,
        'score': outgoing - incoming,
      });
    }

    rankings.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    for (int i = 0; i < rankings.length; i++) {
      rankings[i]['rank'] = i + 1;
    }

    return rankings;
  }
}
