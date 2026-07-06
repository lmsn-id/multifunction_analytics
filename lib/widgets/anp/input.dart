// input.dart - PERBAIKAN LENGKAP
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InputAnpWidget extends StatefulWidget {
  final List<String> alternativeNames;
  final List<String> criteriaNames;
  final List<List<double>> criteriaMatrix;
  final Map<String, List<List<double>>> alternativeMatrices;
  final Map<String, List<List<double>>> innerDependenceMatrices;
  final List<List<double>> clusterWeightMatrix;

  final Function({
    required List<String> alternativeNames,
    required List<String> criteriaNames,
    required List<List<double>> criteriaMatrix,
    required Map<String, List<List<double>>> alternativeMatrices,
    required Map<String, List<List<double>>> innerDependenceMatrices,
    required List<List<double>> clusterWeightMatrix,
  })
  onDataChanged;

  const InputAnpWidget({
    super.key,
    required this.alternativeNames,
    required this.criteriaNames,
    required this.criteriaMatrix,
    required this.alternativeMatrices,
    required this.innerDependenceMatrices,
    required this.clusterWeightMatrix,
    required this.onDataChanged,
  });

  @override
  State<InputAnpWidget> createState() => _InputAnpWidgetState();
}

class _InputAnpWidgetState extends State<InputAnpWidget> {
  // Controllers
  late List<TextEditingController> altNameControllers;
  late List<TextEditingController> critNameControllers;

  // Matrix controllers
  late List<List<TextEditingController>> criteriaMatrixControllers;
  late Map<String, List<List<TextEditingController>>>
  alternativeMatrixControllers;
  late Map<String, List<List<TextEditingController>>>
  innerDependenceControllers;
  late List<List<TextEditingController>> clusterWeightControllers;

  int altCount = 0;
  int critCount = 0;

  // Collapse state untuk setiap section
  bool _showCriteriaMatrix = true;
  bool _showAlternativeMatrices = true;
  bool _showInnerDependence = true;
  bool _showClusterWeight = true;

  @override
  void initState() {
    super.initState();
    altCount = widget.alternativeNames.length;
    critCount = widget.criteriaNames.length;
    _initControllers();
  }

  @override
  void dispose() {
    _disposeAllControllers();
    super.dispose();
  }

  void _initControllers() {
    // Alternative name controllers
    altNameControllers = List.generate(
      altCount,
      (i) => TextEditingController(text: widget.alternativeNames[i]),
    );

    // Criteria name controllers
    critNameControllers = List.generate(
      critCount,
      (i) => TextEditingController(text: widget.criteriaNames[i]),
    );

    // Criteria matrix controllers
    criteriaMatrixControllers = List.generate(
      critCount,
      (i) => List.generate(critCount, (j) {
        final value = widget.criteriaMatrix[i][j];
        return TextEditingController(
          text: value == 0 ? '' : value.toStringAsFixed(2),
        );
      }),
    );

    // Alternative matrices controllers
    alternativeMatrixControllers = {};
    for (final criterion in widget.criteriaNames) {
      final matrix =
          widget.alternativeMatrices[criterion] ??
          List.generate(altCount, (_) => List.filled(altCount, 1.0));
      alternativeMatrixControllers[criterion] = List.generate(
        altCount,
        (i) => List.generate(altCount, (j) {
          final value = matrix[i][j];
          return TextEditingController(
            text: value == 0 ? '' : value.toStringAsFixed(2),
          );
        }),
      );
    }

    // Inner dependence controllers
    innerDependenceControllers = {};
    for (final criterion in widget.criteriaNames) {
      final matrix =
          widget.innerDependenceMatrices[criterion] ??
          List.generate(critCount, (_) => List.filled(critCount, 1.0));
      innerDependenceControllers[criterion] = List.generate(
        critCount,
        (i) => List.generate(critCount, (j) {
          final value = matrix[i][j];
          return TextEditingController(
            text: value == 0 ? '' : value.toStringAsFixed(2),
          );
        }),
      );
    }

    // Cluster weight controllers
    clusterWeightControllers = List.generate(
      2,
      (i) => List.generate(2, (j) {
        final value = widget.clusterWeightMatrix[i][j];
        return TextEditingController(
          text: value == 0 ? '' : value.toStringAsFixed(2),
        );
      }),
    );
  }

  void _disposeAllControllers() {
    for (var controller in altNameControllers) {
      controller.dispose();
    }
    for (var controller in critNameControllers) {
      controller.dispose();
    }
    for (var row in criteriaMatrixControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    for (var entry in alternativeMatrixControllers.values) {
      for (var row in entry) {
        for (var controller in row) {
          controller.dispose();
        }
      }
    }
    for (var entry in innerDependenceControllers.values) {
      for (var row in entry) {
        for (var controller in row) {
          controller.dispose();
        }
      }
    }
    for (var row in clusterWeightControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
  }

  void _notifyDataChanged() {
    try {
      // Get criteria matrix
      final criteriaMatrix = List.generate(critCount, (i) {
        return List.generate(critCount, (j) {
          final text = criteriaMatrixControllers[i][j].text;
          return text.isEmpty ? 0.0 : double.tryParse(text) ?? 0.0;
        });
      });

      // Get alternative matrices
      final alternativeMatrices = <String, List<List<double>>>{};
      for (final criterion in widget.criteriaNames) {
        final controllers = alternativeMatrixControllers[criterion]!;
        final matrix = List.generate(altCount, (i) {
          return List.generate(altCount, (j) {
            final text = controllers[i][j].text;
            return text.isEmpty ? 0.0 : double.tryParse(text) ?? 0.0;
          });
        });
        alternativeMatrices[criterion] = matrix;
      }

      // Get inner dependence matrices
      final innerDependenceMatrices = <String, List<List<double>>>{};
      for (final criterion in widget.criteriaNames) {
        final controllers = innerDependenceControllers[criterion]!;
        final matrix = List.generate(critCount, (i) {
          return List.generate(critCount, (j) {
            final text = controllers[i][j].text;
            return text.isEmpty ? 0.0 : double.tryParse(text) ?? 0.0;
          });
        });
        innerDependenceMatrices[criterion] = matrix;
      }

      // Get cluster weight matrix
      final clusterWeightMatrix = List.generate(2, (i) {
        return List.generate(2, (j) {
          final text = clusterWeightControllers[i][j].text;
          return text.isEmpty ? 0.0 : double.tryParse(text) ?? 0.0;
        });
      });

      final alternativeNames = altNameControllers.map((c) => c.text).toList();
      final criteriaNames = critNameControllers.map((c) => c.text).toList();

      widget.onDataChanged(
        alternativeNames: alternativeNames,
        criteriaNames: criteriaNames,
        criteriaMatrix: criteriaMatrix,
        alternativeMatrices: alternativeMatrices,
        innerDependenceMatrices: innerDependenceMatrices,
        clusterWeightMatrix: clusterWeightMatrix,
      );
    } catch (e) {
      // ignore
    }
  }

  void _addAlternative() {
    setState(() {
      altCount++;
      altNameControllers.add(
        TextEditingController(text: 'Alternatif $altCount'),
      );

      // Add row & column to all alternative matrices
      for (final criterion in widget.criteriaNames) {
        final controllers = alternativeMatrixControllers[criterion]!;
        controllers.add(
          List.generate(altCount, (j) {
            return TextEditingController(text: j == altCount - 1 ? '1.00' : '');
          }),
        );
        for (int i = 0; i < altCount - 1; i++) {
          controllers[i].add(TextEditingController(text: ''));
        }
      }
    });
    _notifyDataChanged();
  }

  void _addCriteria() {
    setState(() {
      critCount++;
      critNameControllers.add(
        TextEditingController(text: 'Kriteria $critCount'),
      );

      // Add row & column to criteria matrix
      for (int i = 0; i < critCount; i++) {
        if (i == critCount - 1) {
          criteriaMatrixControllers.add(
            List.generate(critCount, (j) {
              return TextEditingController(text: i == j ? '1.00' : '');
            }),
          );
        } else {
          criteriaMatrixControllers[i].add(TextEditingController(text: ''));
        }
      }

      // Add new criterion to alternative matrices
      final newMatrix = List.generate(altCount, (_) {
        return List.generate(altCount, (_) {
          return TextEditingController(text: '');
        });
      });
      for (int i = 0; i < altCount; i++) {
        newMatrix[i][i].text = '1.00';
      }
      alternativeMatrixControllers['Kriteria $critCount'] = newMatrix;

      // Add new criterion to inner dependence matrices
      final newInnerMatrix = List.generate(critCount, (_) {
        return List.generate(critCount, (_) {
          return TextEditingController(text: '');
        });
      });
      for (int i = 0; i < critCount; i++) {
        newInnerMatrix[i][i].text = '1.00';
      }
      innerDependenceControllers['Kriteria $critCount'] = newInnerMatrix;

      // Add row & column to existing inner dependence matrices
      for (final criterion in widget.criteriaNames) {
        final controllers = innerDependenceControllers[criterion]!;
        controllers.add(
          List.generate(critCount, (j) {
            return TextEditingController(
              text: j == critCount - 1 ? '1.00' : '',
            );
          }),
        );
        for (int i = 0; i < critCount - 1; i++) {
          controllers[i].add(TextEditingController(text: ''));
        }
      }
    });
    _notifyDataChanged();
  }

  void _removeAlternative(int index) {
    if (altCount <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 2 alternatif'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    setState(() {
      altCount--;
      altNameControllers[index].dispose();
      altNameControllers.removeAt(index);

      for (final criterion in widget.criteriaNames) {
        final controllers = alternativeMatrixControllers[criterion]!;
        for (var controller in controllers[index]) {
          controller.dispose();
        }
        controllers.removeAt(index);
        for (int i = 0; i < altCount; i++) {
          controllers[i][index].dispose();
          controllers[i].removeAt(index);
        }
      }
    });
    _notifyDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildButton(
              label: 'Tambah Alternatif',
              icon: Icons.person_add,
              color: Colors.blue,
              onPressed: _addAlternative,
            ),
            _buildButton(
              label: 'Tambah Kriteria',
              icon: Icons.add_chart,
              color: Colors.green,
              onPressed: _addCriteria,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$altCount Alternatif × $critCount Kriteria',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ============================================================
        // SECTION 1: KRITERIA MATRIX
        // ============================================================
        _buildSection(
          isDark: isDark,
          isDesktop: isDesktop,
          title: 'Pairwise Comparison - Kriteria',
          subtitle: 'Nilai: 1 (sama penting) - 9 (sangat penting)',
          icon: Icons.table_chart,
          isExpanded: _showCriteriaMatrix,
          onToggle: () {
            setState(() {
              _showCriteriaMatrix = !_showCriteriaMatrix;
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth - 16;
              final double labelWidth = isDesktop ? 90 : 60;
              final double remainingWidth = availableWidth - labelWidth;
              final double cellSize = critCount > 0
                  ? (remainingWidth / critCount).clamp(
                      isDesktop ? 70 : 50,
                      isDesktop ? 150 : 100,
                    )
                  : (isDesktop ? 120 : 80);

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 350,
                      minWidth: availableWidth,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: _buildPairwiseMatrixTable(
                        context: context,
                        isDark: isDark,
                        isDesktop: isDesktop,
                        size: critCount,
                        rowLabels: critNameControllers,
                        matrix: criteriaMatrixControllers,
                        labelPrefix: 'Kriteria',
                        cellSize: cellSize,
                        labelWidth: labelWidth,
                        onChanged: (i, j) => _notifyDataChanged(),
                        isRemovable: false,
                        onRemove: null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ============================================================
        // SECTION 2: ALTERNATIF MATRICES
        // ============================================================
        _buildSection(
          isDark: isDark,
          isDesktop: isDesktop,
          title: 'Pairwise Comparison - Alternatif per Kriteria',
          subtitle: 'Bandingkan alternatif untuk setiap kriteria',
          icon: Icons.people,
          isExpanded: _showAlternativeMatrices,
          onToggle: () {
            setState(() {
              _showAlternativeMatrices = !_showAlternativeMatrices;
            });
          },
          child: Column(
            children: widget.criteriaNames.asMap().entries.map((entry) {
              final index = entry.key;
              final criterion = entry.value;
              final controllers = alternativeMatrixControllers[criterion]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Kriteria: $criterion',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double availableWidth = constraints.maxWidth - 16;
                      final double labelWidth = isDesktop ? 90 : 60;
                      final double remainingWidth = availableWidth - labelWidth;
                      final double cellSize = altCount > 0
                          ? (remainingWidth / altCount).clamp(
                              isDesktop ? 70 : 50,
                              isDesktop ? 150 : 100,
                            )
                          : (isDesktop ? 120 : 80);

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 350,
                              minWidth: availableWidth,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: _buildPairwiseMatrixTable(
                                context: context,
                                isDark: isDark,
                                isDesktop: isDesktop,
                                size: altCount,
                                rowLabels: altNameControllers,
                                matrix: controllers,
                                labelPrefix: 'Alternatif',
                                cellSize: cellSize,
                                labelWidth: labelWidth,
                                onChanged: (i, j) => _notifyDataChanged(),
                                isRemovable: true,
                                onRemove: _removeAlternative,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // ============================================================
        // SECTION 3: INNER DEPENDENCE
        // ============================================================
        _buildSection(
          isDark: isDark,
          isDesktop: isDesktop,
          title: 'Inner Dependence (Network) - Antar Kriteria',
          subtitle: 'Hubungan saling ketergantungan antar kriteria',
          icon: Icons.share,
          isExpanded: _showInnerDependence,
          onToggle: () {
            setState(() {
              _showInnerDependence = !_showInnerDependence;
            });
          },
          child: Column(
            children: widget.criteriaNames.asMap().entries.map((entry) {
              final index = entry.key;
              final criterion = entry.value;
              final controllers = innerDependenceControllers[criterion]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Pengaruh terhadap: $criterion',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double availableWidth = constraints.maxWidth - 16;
                      final double labelWidth = isDesktop ? 90 : 60;
                      final double remainingWidth = availableWidth - labelWidth;
                      final double cellSize = critCount > 0
                          ? (remainingWidth / critCount).clamp(
                              isDesktop ? 70 : 50,
                              isDesktop ? 150 : 100,
                            )
                          : (isDesktop ? 120 : 80);

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 350,
                              minWidth: availableWidth,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: _buildPairwiseMatrixTable(
                                context: context,
                                isDark: isDark,
                                isDesktop: isDesktop,
                                size: critCount,
                                rowLabels: critNameControllers,
                                matrix: controllers,
                                labelPrefix: 'Kriteria',
                                cellSize: cellSize,
                                labelWidth: labelWidth,
                                onChanged: (i, j) => _notifyDataChanged(),
                                isRemovable: false,
                                onRemove: null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // ============================================================
        // SECTION 4: CLUSTER WEIGHT
        // ============================================================
        _buildSection(
          isDark: isDark,
          isDesktop: isDesktop,
          title: 'Cluster Weight Matrix',
          subtitle: 'Bobot antar cluster (Kriteria ↔ Alternatif)',
          icon: Icons.balance,
          isExpanded: _showClusterWeight,
          onToggle: () {
            setState(() {
              _showClusterWeight = !_showClusterWeight;
            });
          },
          child: _buildClusterWeight(context, isDark, isDesktop),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 1,
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required bool isDesktop,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          // Header yang bisa di-click
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: isDesktop ? 20 : 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: isDesktop ? 11 : 9,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (isExpanded)
            Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE BUILDER
  // ============================================================
  Widget _buildPairwiseMatrixTable({
    required BuildContext context,
    required bool isDark,
    required bool isDesktop,
    required int size,
    required List<TextEditingController> rowLabels,
    required List<List<TextEditingController>> matrix,
    required String labelPrefix,
    required double cellSize,
    required double labelWidth,
    required Function(int, int) onChanged,
    required bool isRemovable,
    required void Function(int)? onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              SizedBox(
                width: labelWidth,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    labelPrefix,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 12 : 9,
                      color: isDark ? Colors.white : Colors.blue[800],
                    ),
                  ),
                ),
              ),
              ...List.generate(size, (j) {
                final label = rowLabels[j].text.isNotEmpty
                    ? rowLabels[j].text
                    : '$labelPrefix ${j + 1}';
                return SizedBox(
                  width: cellSize,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: isDesktop ? 10 : 8,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.blue[800],
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRemovable && size > 2)
                          GestureDetector(
                            onTap: () => onRemove?.call(j),
                            child: Icon(
                              Icons.close,
                              size: isDesktop ? 16 : 12,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          // Data rows
          ...List.generate(size, (i) {
            return Row(
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            rowLabels[i].text.isNotEmpty
                                ? rowLabels[i].text
                                : '$labelPrefix ${i + 1}',
                            style: TextStyle(
                              fontSize: isDesktop ? 11 : 8,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRemovable && size > 2)
                          GestureDetector(
                            onTap: () => onRemove?.call(i),
                            child: Icon(
                              Icons.close,
                              size: isDesktop ? 16 : 12,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                ...List.generate(size, (j) {
                  final isDiagonal = i == j;
                  final text = matrix[i][j].text;
                  final hasValue =
                      text.isNotEmpty &&
                      double.tryParse(text) != null &&
                      double.tryParse(text)! > 0;

                  return SizedBox(
                    width: cellSize,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: TextField(
                        controller: matrix[i][j],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: isDiagonal ? '1' : '',
                          hintStyle: TextStyle(
                            fontSize: isDesktop ? 11 : 8,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                              color: isDiagonal
                                  ? Colors.blue.withValues(alpha: 0.5)
                                  : (hasValue
                                        ? Colors.green.withValues(alpha: 0.5)
                                        : Colors.grey[300]!),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                              color: isDiagonal
                                  ? Colors.blue.withValues(alpha: 0.5)
                                  : (hasValue
                                        ? Colors.green.withValues(alpha: 0.5)
                                        : Colors.grey[300]!),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: Color(0xFF1A237E),
                              width: 1.5,
                            ),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          suffixText: isDiagonal ? '✓' : null,
                          suffixStyle: TextStyle(
                            fontSize: isDesktop ? 11 : 8,
                            color: Colors.blue,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: isDesktop ? 13 : 9,
                          color: isDiagonal
                              ? Colors.blue
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: isDiagonal ? FontWeight.bold : null,
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (_) => onChanged(i, j),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // CLUSTER WEIGHT
  // ============================================================
  Widget _buildClusterWeight(
    BuildContext context,
    bool isDark,
    bool isDesktop,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: isDesktop ? 100 : 70,
                  child: const SizedBox.shrink(),
                ),
                _buildWeightHeader('Kriteria', isDark, isDesktop),
                _buildWeightHeader('Alternatif', isDark, isDesktop),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: isDesktop ? 100 : 70,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Kriteria',
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _buildWeightInput(0, 0, isDark, isDesktop),
                _buildWeightInput(0, 1, isDark, isDesktop),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: isDesktop ? 100 : 70,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Alternatif',
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _buildWeightInput(1, 0, isDark, isDesktop),
                _buildWeightInput(1, 1, isDark, isDesktop),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightHeader(String label, bool isDark, bool isDesktop) {
    return Container(
      width: isDesktop ? 100 : 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.blue[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isDesktop ? 11 : 9,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.blue[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWeightInput(int row, int col, bool isDark, bool isDesktop) {
    return Container(
      width: isDesktop ? 100 : 70,
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: clusterWeightControllers[row][col],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
        ),
        style: TextStyle(
          fontSize: isDesktop ? 13 : 9,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        textAlign: TextAlign.center,
        onChanged: (_) => _notifyDataChanged(),
      ),
    );
  }
}
