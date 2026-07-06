import 'dart:math' as math;

class TopsisCalculator {
  Future<Map<String, dynamic>> calculate({
    required List<List<double>> matrix,
    required List<double> weights,
    required List<bool> isBenefits,
    required List<String> alternativeNames,
  }) async {
    int rows = matrix.length;
    int cols = matrix[0].length;

    // =========================
    // 1. NORMALISASI MATRIX
    // =========================
    final normalized = _normalizeMatrix(matrix);

    // =========================
    // 2. NORMALISASI BOBOT
    // =========================
    final normalizedWeights = _normalizeWeights(weights);

    // =========================
    // 3. WEIGHTED MATRIX
    // =========================
    final weightedMatrix = _weightedMatrix(normalized, normalizedWeights);

    // =========================
    // 4. IDEAL SOLUTIONS
    // =========================
    final (idealPositive, idealNegative) = _idealSolutions(
      weightedMatrix,
      isBenefits,
    );

    // =========================
    // 5. DISTANCES
    // =========================
    final distances = _calculateDistances(
      weightedMatrix,
      idealPositive,
      idealNegative,
    );

    // =========================
    // 6. PREFERENCE SCORE
    // =========================
    final scores = distances.map((d) {
      final dPos = d['positive']!;
      final dNeg = d['negative']!;

      return (dPos + dNeg == 0) ? 0.0 : dNeg / (dPos + dNeg);
    }).toList();

    // =========================
    // 7. RANKING
    // =========================
    final rankings = List.generate(rows, (i) {
      return {'alternative': alternativeNames[i], 'score': scores[i]};
    });

    rankings.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    // =========================
    // OUTPUT STEP JURNAL
    // =========================
    return {
      'normalized_matrix': normalized,
      'normalized_weights': normalizedWeights,
      'weighted_matrix': weightedMatrix,
      'ideal_positive': idealPositive,
      'ideal_negative': idealNegative,
      'distances': distances,
      'rankings': rankings,
      'summary': {
        'metode': 'TOPSIS',
        'jumlah_alternatif': rows,
        'jumlah_kriteria': cols,
        'alternatif_terbaik': rankings.first['alternative'],
        'skor_terbaik': rankings.first['score'],
      },
    };
  }

  // =========================
  // NORMALISASI VECTOR (STANDARD TOPSIS)
  // =========================
  List<List<double>> _normalizeMatrix(List<List<double>> matrix) {
    int rows = matrix.length;
    int cols = matrix[0].length;

    final normalized = List.generate(rows, (_) => List.filled(cols, 0.0));

    for (int j = 0; j < cols; j++) {
      double sumSquares = 0;

      for (int i = 0; i < rows; i++) {
        sumSquares += math.pow(matrix[i][j], 2);
      }

      double denom = math.sqrt(sumSquares);

      for (int i = 0; i < rows; i++) {
        normalized[i][j] = denom == 0 ? 0 : matrix[i][j] / denom;
      }
    }

    return normalized;
  }

  // =========================
  // NORMALISASI BOBOT
  // =========================
  List<double> _normalizeWeights(List<double> weights) {
    double total = weights.fold(0, (a, b) => a + b);

    return weights.map((w) => w / total).toList();
  }

  // =========================
  // WEIGHTED MATRIX
  // =========================
  List<List<double>> _weightedMatrix(
    List<List<double>> normalized,
    List<double> weights,
  ) {
    int rows = normalized.length;
    int cols = normalized[0].length;

    final weighted = List.generate(rows, (_) => List.filled(cols, 0.0));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        weighted[i][j] = normalized[i][j] * weights[j];
      }
    }

    return weighted;
  }

  // =========================
  // IDEAL SOLUTIONS
  // =========================
  (List<double>, List<double>) _idealSolutions(
    List<List<double>> matrix,
    List<bool> isBenefits,
  ) {
    int cols = matrix[0].length;

    final positive = List.filled(cols, 0.0);
    final negative = List.filled(cols, 0.0);

    for (int j = 0; j < cols; j++) {
      final column = matrix.map((e) => e[j]).toList();

      double maxVal = column.reduce(math.max);
      double minVal = column.reduce(math.min);

      if (isBenefits[j]) {
        positive[j] = maxVal;
        negative[j] = minVal;
      } else {
        positive[j] = minVal;
        negative[j] = maxVal;
      }
    }

    return (positive, negative);
  }

  // =========================
  // DISTANCES
  // =========================
  List<Map<String, double>> _calculateDistances(
    List<List<double>> matrix,
    List<double> idealPositive,
    List<double> idealNegative,
  ) {
    return matrix.map((row) {
      double dPos = 0;
      double dNeg = 0;

      for (int j = 0; j < row.length; j++) {
        dPos += math.pow(row[j] - idealPositive[j], 2);
        dNeg += math.pow(row[j] - idealNegative[j], 2);
      }

      return {'positive': math.sqrt(dPos), 'negative': math.sqrt(dNeg)};
    }).toList();
  }
}
