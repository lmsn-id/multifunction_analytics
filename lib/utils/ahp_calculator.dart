class AhpCalculator {
  static const double _epsilon = 1e-6;
  static const double _consistencyRatioThreshold = 0.10;
  static const Map<int, double> _defaultRandomIndex = {
    1: 0.0,
    2: 0.0,
    3: 0.58,
    4: 0.90,
    5: 1.12,
    6: 1.24,
    7: 1.32,
    8: 1.41,
    9: 1.45,
    10: 1.49,
  };

  static Map<String, dynamic> calculate({
    required List<String> alternatives,
    required List<String> criteria,
    required List<List<double>> criteriaComparisonMatrix,
    required Map<String, List<List<double>>> alternativeComparisonMatrices,
    Map<int, double>? customRandomIndex,
  }) {
    final randomIndexTable = customRandomIndex ?? _defaultRandomIndex;

    _validateInput(
      alternatives: alternatives,
      criteria: criteria,
      criteriaComparisonMatrix: criteriaComparisonMatrix,
      alternativeComparisonMatrices: alternativeComparisonMatrices,
    );

    _validatePairwiseMatrix(
      matrix: criteriaComparisonMatrix,
      expectedSize: criteria.length,
      label: 'Kriteria',
    );

    for (final criterionName in criteria) {
      _validatePairwiseMatrix(
        matrix: alternativeComparisonMatrices[criterionName]!,
        expectedSize: alternatives.length,
        label: 'Alternatif terhadap "$criterionName"',
      );
    }

    final criteriaAnalysis = _analyzeMatrix(
      matrix: criteriaComparisonMatrix,
      randomIndexTable: randomIndexTable,
    );

    final criteriaPriorityVector =
        criteriaAnalysis['priority_vector'] as List<double>;

    final Map<String, dynamic> alternativeAnalysis = {};
    final Map<String, List<double>> alternativePriorityByCriteria = {};

    for (final criterionName in criteria) {
      final analysis = _analyzeMatrix(
        matrix: alternativeComparisonMatrices[criterionName]!,
        randomIndexTable: randomIndexTable,
      );

      alternativeAnalysis[criterionName] = analysis;
      alternativePriorityByCriteria[criterionName] =
          analysis['priority_vector'] as List<double>;
    }

    final globalPriority = calculateGlobalPriority(
      alternatives: alternatives,
      criteria: criteria,
      criteriaPriorityVector: criteriaPriorityVector,
      alternativePriorityByCriteria: alternativePriorityByCriteria,
    );

    final rankings = calculateRanking(
      alternatives: alternatives,
      globalPriority: globalPriority,
    );

    final summary = _buildSummary(
      alternatives: alternatives,
      criteria: criteria,
      criteriaAnalysis: criteriaAnalysis,
      rankings: rankings,
    );

    return {
      'criteria_analysis': criteriaAnalysis,
      'alternative_analysis': alternativeAnalysis,
      'criteria_priority_vector': criteriaPriorityVector,
      'global_priority': globalPriority,
      'rankings': rankings,
      'summary': summary,
    };
  }

  static void _validateInput({
    required List<String> alternatives,
    required List<String> criteria,
    required List<List<double>> criteriaComparisonMatrix,
    required Map<String, List<List<double>>> alternativeComparisonMatrices,
  }) {
    if (alternatives.isEmpty) {
      throw Exception('Daftar alternatif tidak boleh kosong.');
    }

    if (criteria.isEmpty) {
      throw Exception('Daftar kriteria tidak boleh kosong.');
    }

    if (alternatives.toSet().length != alternatives.length) {
      throw Exception('Nama alternatif harus unik.');
    }

    if (criteria.toSet().length != criteria.length) {
      throw Exception('Nama kriteria harus unik.');
    }

    for (final criterionName in criteria) {
      if (!alternativeComparisonMatrices.containsKey(criterionName)) {
        throw Exception(
          'Matrix perbandingan alternatif untuk kriteria "$criterionName" '
          'tidak ditemukan.',
        );
      }
    }
  }

  static void _validatePairwiseMatrix({
    required List<List<double>> matrix,
    required int expectedSize,
    required String label,
  }) {
    final n = matrix.length;

    if (n != expectedSize) {
      throw Exception(
        'Ukuran matrix "$label" ($n) tidak sesuai jumlah item ($expectedSize).',
      );
    }

    for (var i = 0; i < n; i++) {
      if (matrix[i].length != n) {
        throw Exception('Matrix "$label" harus berbentuk persegi (n x n).');
      }
    }

    for (var i = 0; i < n; i++) {
      if ((matrix[i][i] - 1.0).abs() > _epsilon) {
        throw Exception(
          'Diagonal matrix "$label" harus bernilai 1 '
          '(ditemukan ${matrix[i][i]} pada indeks [$i][$i]).',
        );
      }
    }

    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        if (i == j) continue;

        final expectedReciprocal = 1.0 / matrix[j][i];
        if ((matrix[i][j] - expectedReciprocal).abs() > _epsilon) {
          throw Exception(
            'Matrix "$label" tidak reciprocal pada [$i][$j]: '
            'nilai (${matrix[i][j]}) seharusnya 1/(${matrix[j][i]}).',
          );
        }
      }
    }
  }

  static List<List<double>> normalizeMatrix(List<List<double>> matrix) {
    final n = matrix.length;
    final columnSums = List<double>.filled(n, 0.0);

    for (var j = 0; j < n; j++) {
      for (var i = 0; i < n; i++) {
        columnSums[j] += matrix[i][j];
      }
    }

    return List.generate(
      n,
      (i) => List.generate(n, (j) => matrix[i][j] / columnSums[j]),
    );
  }

  static List<double> calculatePriorityVector(
    List<List<double>> normalizedMatrix,
  ) {
    final n = normalizedMatrix.length;

    return List.generate(n, (i) {
      final rowSum = normalizedMatrix[i].reduce((a, b) => a + b);
      return rowSum / n;
    });
  }

  static double calculateLambdaMax(
    List<List<double>> matrix,
    List<double> priorityVector,
  ) {
    final n = matrix.length;
    final weightedSumVector = List<double>.filled(n, 0.0);

    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        weightedSumVector[i] += matrix[i][j] * priorityVector[j];
      }
    }

    var lambdaSum = 0.0;
    for (var i = 0; i < n; i++) {
      lambdaSum += weightedSumVector[i] / priorityVector[i];
    }

    return lambdaSum / n;
  }

  static double calculateConsistencyIndex({
    required double lambdaMax,
    required int n,
  }) {
    if (n <= 1) return 0.0;
    return (lambdaMax - n) / (n - 1);
  }

  static double _getRandomIndex(int n, Map<int, double> randomIndexTable) {
    if (n <= 2) return 0.0;

    final ri = randomIndexTable[n];
    if (ri == null) {
      throw Exception(
        'Random Index (RI) untuk n = $n tidak tersedia pada tabel. '
        'Berikan customRandomIndex untuk ukuran matrix ini.',
      );
    }

    return ri;
  }

  static double calculateConsistencyRatio({
    required double consistencyIndex,
    required double randomIndex,
  }) {
    if (randomIndex == 0.0) return 0.0;
    return consistencyIndex / randomIndex;
  }

  static Map<String, dynamic> _analyzeMatrix({
    required List<List<double>> matrix,
    required Map<int, double> randomIndexTable,
  }) {
    final n = matrix.length;

    final normalizedMatrix = normalizeMatrix(matrix);
    final priorityVector = calculatePriorityVector(normalizedMatrix);
    final lambdaMax = calculateLambdaMax(matrix, priorityVector);
    final consistencyIndex = calculateConsistencyIndex(
      lambdaMax: lambdaMax,
      n: n,
    );
    final randomIndex = _getRandomIndex(n, randomIndexTable);
    final consistencyRatio = calculateConsistencyRatio(
      consistencyIndex: consistencyIndex,
      randomIndex: randomIndex,
    );
    final isConsistent = consistencyRatio <= _consistencyRatioThreshold;

    return {
      'pairwise_matrix': matrix,
      'normalized_matrix': normalizedMatrix,
      'priority_vector': priorityVector,
      'lambda_max': lambdaMax,
      'consistency_index': consistencyIndex,
      'consistency_ratio': consistencyRatio,
      'random_index': randomIndex,
      'is_consistent': isConsistent,
    };
  }

  static Map<String, double> calculateGlobalPriority({
    required List<String> alternatives,
    required List<String> criteria,
    required List<double> criteriaPriorityVector,
    required Map<String, List<double>> alternativePriorityByCriteria,
  }) {
    final Map<String, double> globalPriority = {
      for (final alternative in alternatives) alternative: 0.0,
    };

    for (var k = 0; k < criteria.length; k++) {
      final criterionName = criteria[k];
      final criterionWeight = criteriaPriorityVector[k];
      final alternativePriorities =
          alternativePriorityByCriteria[criterionName]!;

      for (var i = 0; i < alternatives.length; i++) {
        final alternativeName = alternatives[i];
        globalPriority[alternativeName] =
            globalPriority[alternativeName]! +
            (alternativePriorities[i] * criterionWeight);
      }
    }

    return globalPriority;
  }

  static List<Map<String, dynamic>> calculateRanking({
    required List<String> alternatives,
    required Map<String, double> globalPriority,
  }) {
    final sortedAlternatives = List<String>.from(alternatives)
      ..sort((a, b) => globalPriority[b]!.compareTo(globalPriority[a]!));

    return List.generate(sortedAlternatives.length, (index) {
      final alternativeName = sortedAlternatives[index];
      return {
        'alternative': alternativeName,
        'priority': globalPriority[alternativeName],
        'rank': index + 1,
      };
    });
  }

  static Map<String, dynamic> _buildSummary({
    required List<String> alternatives,
    required List<String> criteria,
    required Map<String, dynamic> criteriaAnalysis,
    required List<Map<String, dynamic>> rankings,
  }) {
    final bestResult = rankings.firstWhere((item) => item['rank'] == 1);

    return {
      'total_alternatives': alternatives.length,
      'total_criteria': criteria.length,
      'criteria_consistency_ratio': criteriaAnalysis['consistency_ratio'],
      'is_criteria_consistent': criteriaAnalysis['is_consistent'],
      'best_alternative': bestResult['alternative'],
      'best_score': bestResult['priority'],
    };
  }
}
