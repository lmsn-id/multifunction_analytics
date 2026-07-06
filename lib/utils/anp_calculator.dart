class AnpCalculator {
  static const double _consistencyThreshold = 0.1;

  static const double _defaultTolerance = 1e-10;

  static const int _defaultMaxIterations = 200;

  static const List<double> _randomIndexTable = [
    0.0,
    0.0,
    0.0,
    0.58,
    0.90,
    1.12,
    1.24,
    1.32,
    1.41,
    1.45,
    1.49,
  ];

  static Map<String, dynamic> calculate({
    required List<String> alternatives,
    required List<String> criteria,
    required List<List<double>> criteriaComparisonMatrix,
    required Map<String, List<List<double>>> alternativeComparisonMatrices,
    Map<String, List<List<double>>>? criteriaInnerDependenceMatrices,
    List<List<double>>? clusterWeightMatrix,
    double tolerance = _defaultTolerance,
    int maxIterations = _defaultMaxIterations,
  }) {
    _validateInput(
      alternatives: alternatives,
      criteria: criteria,
      criteriaComparisonMatrix: criteriaComparisonMatrix,
      alternativeComparisonMatrices: alternativeComparisonMatrices,
      criteriaInnerDependenceMatrices: criteriaInnerDependenceMatrices,
    );

    final normalizedCriteriaMatrix = normalizeMatrix(criteriaComparisonMatrix);
    final criteriaPriorityVector = calculatePriorityVector(
      normalizedCriteriaMatrix,
    );
    final criteriaLambdaMax = calculateLambdaMax(
      criteriaComparisonMatrix,
      criteriaPriorityVector,
    );
    final criteriaConsistencyIndex = calculateConsistencyIndex(
      criteriaLambdaMax,
      criteria.length,
    );
    final criteriaRandomIndex = getRandomIndex(criteria.length);
    final criteriaConsistencyRatio = calculateConsistencyRatio(
      criteriaConsistencyIndex,
      criteriaRandomIndex,
    );
    final isCriteriaConsistent =
        criteriaConsistencyRatio <= _consistencyThreshold;

    final alternativeAnalysis = _analyzeAlternativeMatrices(
      alternatives: alternatives,
      criteria: criteria,
      alternativeComparisonMatrices: alternativeComparisonMatrices,
    );

    final innerDependenceAnalysis = _analyzeInnerDependenceMatrices(
      criteria: criteria,
      criteriaInnerDependenceMatrices: criteriaInnerDependenceMatrices,
    );

    final nodeLabels = [...criteria, ...alternatives];
    final unweightedSupermatrix = buildUnweightedSupermatrix(
      criteria: criteria,
      alternatives: alternatives,
      criteriaPriorityVectors: innerDependenceAnalysis.priorityVectors,
      alternativePriorityVectors: alternativeAnalysis.priorityVectors,
    );

    final effectiveClusterWeightMatrix =
        clusterWeightMatrix ??
        _defaultClusterWeightMatrix(
          hasInnerDependence:
              criteriaInnerDependenceMatrices != null &&
              criteriaInnerDependenceMatrices.isNotEmpty,
        );
    final weightedSupermatrix = buildWeightedSupermatrix(
      unweightedSupermatrix: unweightedSupermatrix,
      criteriaCount: criteria.length,
      alternativesCount: alternatives.length,
      clusterWeightMatrix: effectiveClusterWeightMatrix,
    );

    final limitResult = buildLimitSupermatrix(
      weightedSupermatrix: weightedSupermatrix,
      tolerance: tolerance,
      maxIterations: maxIterations,
    );

    final globalPriority = calculateGlobalPriority(limitResult.matrix);

    final rankings = calculateRanking(
      alternatives: alternatives,
      criteriaCount: criteria.length,
      globalPriority: globalPriority,
    );

    final summary = _buildSummary(
      alternatives: alternatives,
      criteria: criteria,
      lambdaMax: criteriaLambdaMax,
      consistencyIndex: criteriaConsistencyIndex,
      consistencyRatio: criteriaConsistencyRatio,
      isConsistent: isCriteriaConsistent,
      rankings: rankings,
      limitConverged: limitResult.converged,
      iterationsUsed: limitResult.iterationsUsed,
    );

    return {
      'node_labels': nodeLabels,
      'criteria_analysis': {
        'pairwise_matrix': criteriaComparisonMatrix,
        'normalized_matrix': normalizedCriteriaMatrix,
        'priority_vector': criteriaPriorityVector,
        'lambda_max': criteriaLambdaMax,
        'consistency_index': criteriaConsistencyIndex,
        'consistency_ratio': criteriaConsistencyRatio,
        'random_index': criteriaRandomIndex,
        'is_consistent': isCriteriaConsistent,
      },
      'alternative_analysis': alternativeAnalysis.details,
      'inner_dependence_analysis': innerDependenceAnalysis.details,
      'unweighted_supermatrix': unweightedSupermatrix,
      'weighted_supermatrix': weightedSupermatrix,
      'limit_supermatrix': limitResult.matrix,
      'limit_supermatrix_converged': limitResult.converged,
      'limit_supermatrix_iterations': limitResult.iterationsUsed,
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
    Map<String, List<List<double>>>? criteriaInnerDependenceMatrices,
  }) {
    if (alternatives.isEmpty) {
      throw Exception('Daftar alternatif tidak boleh kosong.');
    }
    if (criteria.isEmpty) {
      throw Exception('Daftar kriteria tidak boleh kosong.');
    }
    if (alternatives.toSet().length != alternatives.length) {
      throw Exception('Terdapat nama alternatif yang duplikat.');
    }
    if (criteria.toSet().length != criteria.length) {
      throw Exception('Terdapat nama kriteria yang duplikat.');
    }

    _validatePairwiseMatrix(
      criteriaComparisonMatrix,
      criteria.length,
      'Pairwise Comparison Kriteria',
    );

    for (final criterion in criteria) {
      final matrix = alternativeComparisonMatrices[criterion];
      if (matrix == null) {
        throw Exception(
          'Matrix perbandingan alternatif untuk kriteria "$criterion" '
          'tidak ditemukan.',
        );
      }
      _validatePairwiseMatrix(
        matrix,
        alternatives.length,
        'Pairwise Comparison Alternatif terhadap "$criterion"',
      );
    }

    if (criteriaInnerDependenceMatrices != null) {
      for (final entry in criteriaInnerDependenceMatrices.entries) {
        if (!criteria.contains(entry.key)) {
          throw Exception(
            'Kriteria "${entry.key}" pada inner dependence matrix '
            'tidak terdapat pada daftar kriteria.',
          );
        }
        _validatePairwiseMatrix(
          entry.value,
          criteria.length,
          'Inner Dependence Matrix untuk kriteria "${entry.key}"',
        );
      }
    }
  }

  static void _validatePairwiseMatrix(
    List<List<double>> matrix,
    int expectedSize,
    String matrixName,
  ) {
    if (matrix.length != expectedSize) {
      throw Exception(
        '$matrixName harus berukuran $expectedSize x $expectedSize '
        '(ditemukan ${matrix.length} baris).',
      );
    }

    for (int i = 0; i < matrix.length; i++) {
      if (matrix[i].length != expectedSize) {
        throw Exception(
          '$matrixName tidak berbentuk persegi pada baris ke-$i.',
        );
      }
    }

    const double epsilon = 1e-6;

    for (int i = 0; i < matrix.length; i++) {
      if ((matrix[i][i] - 1.0).abs() > epsilon) {
        throw Exception(
          '$matrixName: nilai diagonal baris ke-$i harus bernilai 1.',
        );
      }
      for (int j = 0; j < matrix.length; j++) {
        if (i == j) continue;
        if (matrix[j][i] == 0) {
          throw Exception(
            '$matrixName: elemen [$j][$i] tidak boleh bernilai 0 '
            'karena digunakan sebagai pembagi reciprocal.',
          );
        }
        final double expectedReciprocal = 1.0 / matrix[j][i];
        if ((matrix[i][j] - expectedReciprocal).abs() > epsilon) {
          throw Exception(
            '$matrixName: nilai [$i][$j] = ${matrix[i][j]} tidak '
            'reciprocal terhadap [$j][$i] = ${matrix[j][i]}. '
            'Seharusnya [$i][$j] = ${expectedReciprocal.toStringAsFixed(4)}.',
          );
        }
      }
    }
  }

  static List<List<double>> normalizeMatrix(List<List<double>> matrix) {
    final int n = matrix.length;
    final List<double> columnSums = List<double>.filled(n, 0.0);

    for (int j = 0; j < n; j++) {
      double sum = 0.0;
      for (int i = 0; i < n; i++) {
        sum += matrix[i][j];
      }
      columnSums[j] = sum;
    }

    return List.generate(
      n,
      (i) => List.generate(
        n,
        (j) => columnSums[j] == 0 ? 0.0 : matrix[i][j] / columnSums[j],
      ),
    );
  }

  static List<double> calculatePriorityVector(
    List<List<double>> normalizedMatrix,
  ) {
    final int n = normalizedMatrix.length;
    return List.generate(n, (i) {
      final double rowSum = normalizedMatrix[i].fold(0.0, (a, b) => a + b);
      return rowSum / n;
    });
  }

  static double calculateLambdaMax(
    List<List<double>> matrix,
    List<double> priorityVector,
  ) {
    final int n = matrix.length;
    final List<double> weightedSum = List<double>.filled(n, 0.0);

    for (int i = 0; i < n; i++) {
      double sum = 0.0;
      for (int j = 0; j < n; j++) {
        sum += matrix[i][j] * priorityVector[j];
      }
      weightedSum[i] = sum;
    }

    double lambdaSum = 0.0;
    int validCount = 0;
    for (int i = 0; i < n; i++) {
      if (priorityVector[i] != 0) {
        lambdaSum += weightedSum[i] / priorityVector[i];
        validCount++;
      }
    }

    return validCount == 0 ? 0.0 : lambdaSum / validCount;
  }

  static double calculateConsistencyIndex(double lambdaMax, int n) {
    if (n <= 1) return 0.0;
    return (lambdaMax - n) / (n - 1);
  }

  static double getRandomIndex(int n) {
    if (n < 0) return 0.0;
    if (n < _randomIndexTable.length) return _randomIndexTable[n];

    return _randomIndexTable.last;
  }

  static double calculateConsistencyRatio(
    double consistencyIndex,
    double randomIndex,
  ) {
    if (randomIndex == 0) return 0.0;
    return consistencyIndex / randomIndex;
  }

  static _MatrixSetAnalysis _analyzeAlternativeMatrices({
    required List<String> alternatives,
    required List<String> criteria,
    required Map<String, List<List<double>>> alternativeComparisonMatrices,
  }) {
    final Map<String, List<double>> priorityVectors = {};
    final Map<String, dynamic> details = {};

    for (final criterion in criteria) {
      final matrix = alternativeComparisonMatrices[criterion]!;
      final normalized = normalizeMatrix(matrix);
      final priorityVector = calculatePriorityVector(normalized);
      final lambdaMax = calculateLambdaMax(matrix, priorityVector);
      final ci = calculateConsistencyIndex(lambdaMax, alternatives.length);
      final ri = getRandomIndex(alternatives.length);
      final cr = calculateConsistencyRatio(ci, ri);

      priorityVectors[criterion] = priorityVector;
      details[criterion] = {
        'pairwise_matrix': matrix,
        'normalized_matrix': normalized,
        'priority_vector': priorityVector,
        'lambda_max': lambdaMax,
        'consistency_index': ci,
        'consistency_ratio': cr,
        'random_index': ri,
        'is_consistent': cr <= _consistencyThreshold,
      };
    }

    return _MatrixSetAnalysis(
      priorityVectors: priorityVectors,
      details: details,
    );
  }

  static _MatrixSetAnalysis _analyzeInnerDependenceMatrices({
    required List<String> criteria,
    Map<String, List<List<double>>>? criteriaInnerDependenceMatrices,
  }) {
    final Map<String, List<double>> priorityVectors = {};
    final Map<String, dynamic> details = {};

    if (criteriaInnerDependenceMatrices == null ||
        criteriaInnerDependenceMatrices.isEmpty) {
      return _MatrixSetAnalysis(
        priorityVectors: priorityVectors,
        details: {
          'note':
              'Tidak ada inner dependence antar kriteria. '
              'Cluster kriteria dianggap independen.',
        },
      );
    }

    for (final criterion in criteria) {
      final matrix = criteriaInnerDependenceMatrices[criterion];
      if (matrix == null) continue;

      final normalized = normalizeMatrix(matrix);
      final priorityVector = calculatePriorityVector(normalized);
      final lambdaMax = calculateLambdaMax(matrix, priorityVector);
      final ci = calculateConsistencyIndex(lambdaMax, criteria.length);
      final ri = getRandomIndex(criteria.length);
      final cr = calculateConsistencyRatio(ci, ri);

      priorityVectors[criterion] = priorityVector;
      details[criterion] = {
        'pairwise_matrix': matrix,
        'normalized_matrix': normalized,
        'priority_vector': priorityVector,
        'lambda_max': lambdaMax,
        'consistency_index': ci,
        'consistency_ratio': cr,
        'random_index': ri,
        'is_consistent': cr <= _consistencyThreshold,
      };
    }

    return _MatrixSetAnalysis(
      priorityVectors: priorityVectors,
      details: details,
    );
  }

  static List<List<double>> buildUnweightedSupermatrix({
    required List<String> criteria,
    required List<String> alternatives,
    required Map<String, List<double>> criteriaPriorityVectors,
    required Map<String, List<double>> alternativePriorityVectors,
  }) {
    final int nc = criteria.length;
    final int na = alternatives.length;
    final int n = nc + na;

    final List<List<double>> supermatrix = List.generate(
      n,
      (_) => List<double>.filled(n, 0.0),
    );

    for (int j = 0; j < nc; j++) {
      final vector = criteriaPriorityVectors[criteria[j]];
      if (vector == null) continue;
      for (int i = 0; i < nc; i++) {
        supermatrix[i][j] = vector[i];
      }
    }

    for (int j = 0; j < nc; j++) {
      final vector = alternativePriorityVectors[criteria[j]];
      if (vector == null) continue;
      for (int i = 0; i < na; i++) {
        supermatrix[nc + i][j] = vector[i];
      }
    }

    return _normalizeSupermatrixColumns(supermatrix);
  }

  static List<List<double>> buildWeightedSupermatrix({
    required List<List<double>> unweightedSupermatrix,
    required int criteriaCount,
    required int alternativesCount,
    required List<List<double>> clusterWeightMatrix,
  }) {
    final int n = criteriaCount + alternativesCount;
    final List<List<double>> weighted = List.generate(
      n,
      (i) => List<double>.from(unweightedSupermatrix[i]),
    );

    for (int i = 0; i < n; i++) {
      final int rowCluster = i < criteriaCount ? 0 : 1;
      for (int j = 0; j < n; j++) {
        final int colCluster = j < criteriaCount ? 0 : 1;
        final double weight = clusterWeightMatrix[rowCluster][colCluster];
        weighted[i][j] = unweightedSupermatrix[i][j] * weight;
      }
    }

    return _normalizeSupermatrixColumns(weighted);
  }

  static _LimitSupermatrixResult buildLimitSupermatrix({
    required List<List<double>> weightedSupermatrix,
    double tolerance = _defaultTolerance,
    int maxIterations = _defaultMaxIterations,
  }) {
    List<List<double>> current = weightedSupermatrix;
    bool converged = false;
    int iterationsUsed = 0;

    for (int k = 0; k < maxIterations; k++) {
      final next = _multiplyMatrices(current, weightedSupermatrix);
      iterationsUsed = k + 1;

      if (_maxAbsoluteDifference(current, next) < tolerance) {
        current = next;
        converged = true;
        break;
      }
      current = next;
    }

    return _LimitSupermatrixResult(
      matrix: current,
      converged: converged,
      iterationsUsed: iterationsUsed,
    );
  }

  static List<double> calculateGlobalPriority(
    List<List<double>> limitSupermatrix,
  ) {
    final int n = limitSupermatrix.length;
    final List<double> rawPriority = List<double>.filled(n, 0.0);

    for (int i = 0; i < n; i++) {
      double sum = 0.0;
      for (int j = 0; j < n; j++) {
        sum += limitSupermatrix[i][j];
      }
      rawPriority[i] = sum / n;
    }

    final double total = rawPriority.fold(0.0, (a, b) => a + b);
    if (total == 0) return rawPriority;

    return rawPriority.map((v) => v / total).toList();
  }

  static List<Map<String, dynamic>> calculateRanking({
    required List<String> alternatives,
    required int criteriaCount,
    required List<double> globalPriority,
  }) {
    final List<double> alternativeScores = List.generate(
      alternatives.length,
      (i) => globalPriority[criteriaCount + i],
    );

    final double total = alternativeScores.fold(0.0, (a, b) => a + b);
    final List<double> normalizedScores = total == 0
        ? alternativeScores
        : alternativeScores.map((v) => v / total).toList();

    final List<Map<String, dynamic>> rankings = List.generate(
      alternatives.length,
      (i) => {'alternative': alternatives[i], 'priority': normalizedScores[i]},
    );

    rankings.sort(
      (a, b) => (b['priority'] as double).compareTo(a['priority'] as double),
    );

    for (int i = 0; i < rankings.length; i++) {
      rankings[i]['rank'] = i + 1;
    }

    return rankings;
  }

  static Map<String, dynamic> _buildSummary({
    required List<String> alternatives,
    required List<String> criteria,
    required double lambdaMax,
    required double consistencyIndex,
    required double consistencyRatio,
    required bool isConsistent,
    required List<Map<String, dynamic>> rankings,
    required bool limitConverged,
    required int iterationsUsed,
  }) {
    final best = rankings.first;

    return {
      'jumlah_alternatif': alternatives.length,
      'jumlah_kriteria': criteria.length,
      'lambda_max': lambdaMax,
      'consistency_index': consistencyIndex,
      'consistency_ratio': consistencyRatio,
      'status_konsistensi': isConsistent
          ? 'Konsisten (CR <= 0.1)'
          : 'Tidak Konsisten (CR > 0.1), pertimbangkan untuk '
                'meninjau ulang pairwise comparison.',
      'alternatif_terbaik': best['alternative'],
      'skor_terbaik': best['priority'],
      'limit_supermatrix_konvergen': limitConverged,
      'jumlah_iterasi': iterationsUsed,
    };
  }

  static List<List<double>> _defaultClusterWeightMatrix({
    required bool hasInnerDependence,
  }) {
    return [
      [hasInnerDependence ? 1.0 : 0.0, 0.0],
      [1.0, 0.0],
    ];
  }

  static List<List<double>> _normalizeSupermatrixColumns(
    List<List<double>> matrix,
  ) {
    final int n = matrix.length;
    final List<List<double>> normalized = List.generate(
      n,
      (_) => List<double>.filled(n, 0.0),
    );

    for (int j = 0; j < n; j++) {
      double columnSum = 0.0;
      for (int i = 0; i < n; i++) {
        columnSum += matrix[i][j];
      }

      if (columnSum == 0) {
        for (int i = 0; i < n; i++) {
          normalized[i][j] = 1.0 / n;
        }
      } else {
        for (int i = 0; i < n; i++) {
          normalized[i][j] = matrix[i][j] / columnSum;
        }
      }
    }

    return normalized;
  }

  static List<List<double>> _multiplyMatrices(
    List<List<double>> a,
    List<List<double>> b,
  ) {
    final int n = a.length;
    final List<List<double>> result = List.generate(
      n,
      (_) => List<double>.filled(n, 0.0),
    );

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        double sum = 0.0;
        for (int k = 0; k < n; k++) {
          sum += a[i][k] * b[k][j];
        }
        result[i][j] = sum;
      }
    }

    return result;
  }

  static double _maxAbsoluteDifference(
    List<List<double>> a,
    List<List<double>> b,
  ) {
    double maxDiff = 0.0;
    for (int i = 0; i < a.length; i++) {
      for (int j = 0; j < a[i].length; j++) {
        final diff = (a[i][j] - b[i][j]).abs();
        if (diff > maxDiff) maxDiff = diff;
      }
    }
    return maxDiff;
  }
}

class _MatrixSetAnalysis {
  final Map<String, List<double>> priorityVectors;
  final Map<String, dynamic> details;

  _MatrixSetAnalysis({required this.priorityVectors, required this.details});
}

class _LimitSupermatrixResult {
  final List<List<double>> matrix;
  final bool converged;
  final int iterationsUsed;

  _LimitSupermatrixResult({
    required this.matrix,
    required this.converged,
    required this.iterationsUsed,
  });
}
