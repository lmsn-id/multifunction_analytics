import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/excel/excel_import_dialog.dart';
import '../../widgets/excel/excel_import_criteria.dart';

class InputMatrixWidget extends StatefulWidget {
  final List<List<double>> initialMatrix;
  final List<String> alternativeNames;
  final List<String> criteriaNames;
  final List<double> initialWeights;
  final List<bool> initialIsBenefits;
  final Function({
    required List<List<double>> matrix,
    required List<double> weights,
    required List<bool> isBenefits,
    required List<String> alternativeNames,
    required List<String> criteriaNames,
  })
  onDataChanged;

  const InputMatrixWidget({
    super.key,
    required this.initialMatrix,
    required this.alternativeNames,
    required this.criteriaNames,
    required this.initialWeights,
    required this.initialIsBenefits,
    required this.onDataChanged,
  });

  @override
  State<InputMatrixWidget> createState() => _InputMatrixWidgetState();
}

class _InputMatrixWidgetState extends State<InputMatrixWidget> {
  late List<List<TextEditingController>> matrixControllers;
  late List<TextEditingController> weightControllers;
  late List<bool> isBenefits;
  late List<TextEditingController> alternativeControllers;
  late List<TextEditingController> criteriaControllers;
  int altCount = 0;
  int critCount = 0;

  @override
  void initState() {
    super.initState();
    altCount = widget.alternativeNames.length;
    critCount = widget.criteriaNames.length;
    isBenefits = List.from(widget.initialIsBenefits);
    _initControllers();
  }

  void _initControllers() {
    matrixControllers = List.generate(
      altCount,
      (i) => List.generate(critCount, (j) {
        final value = widget.initialMatrix[i][j];
        return TextEditingController(text: value == 0 ? '' : value.toString());
      }),
    );
    weightControllers = List.generate(critCount, (j) {
      final value = widget.initialWeights[j];
      return TextEditingController(text: value == 0 ? '' : value.toString());
    });
    alternativeControllers = List.generate(
      altCount,
      (i) => TextEditingController(text: widget.alternativeNames[i]),
    );
    criteriaControllers = List.generate(
      critCount,
      (j) => TextEditingController(text: widget.criteriaNames[j]),
    );
  }

  @override
  void dispose() {
    for (var row in matrixControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    for (var controller in weightControllers) {
      controller.dispose();
    }
    for (var controller in alternativeControllers) {
      controller.dispose();
    }
    for (var controller in criteriaControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showExcelImportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExcelImportDialog(
        onImport: (data) {
          final alternativeNames = data['alternativeNames'] as List<String>;
          final criteriaNames = data['criteriaNames'] as List<String>;
          final matrix = data['matrix'] as List<List<double>>;

          _updateFromExcelData(alternativeNames, criteriaNames, matrix);
          _notifyDataChanged();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Berhasil import ${alternativeNames.length} alternatif dan ${criteriaNames.length} kriteria',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showExcelCriteriaImportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExcelImportCriteriaDialog(
        onImport: (criteriaNames, weights, isBenefits) {
          _updateCriteriaFromExcel(criteriaNames, weights, isBenefits);
          _notifyDataChanged();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil import ${criteriaNames.length} kriteria'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _updateCriteriaFromExcel(
    List<String> criteriaNames,
    List<double> weights,
    List<bool> isBenefits,
  ) {
    setState(() {
      // Dispose old weight controllers
      for (var controller in weightControllers) {
        controller.dispose();
      }
      for (var controller in criteriaControllers) {
        controller.dispose();
      }

      // Update counts
      critCount = criteriaNames.length;

      // Update matrix controllers (tambah kolom jika perlu)
      if (critCount > widget.criteriaNames.length) {
        // Tambah kolom baru
        for (int i = 0; i < altCount; i++) {
          for (int j = widget.criteriaNames.length; j < critCount; j++) {
            matrixControllers[i].add(TextEditingController(text: ''));
          }
        }
      } else if (critCount < widget.criteriaNames.length) {
        // Hapus kolom yang tidak perlu
        for (int i = 0; i < altCount; i++) {
          for (int j = critCount; j < widget.criteriaNames.length; j++) {
            matrixControllers[i][j].dispose();
          }
          matrixControllers[i] = matrixControllers[i].sublist(0, critCount);
        }
      }

      // Update weight controllers
      weightControllers = List.generate(
        critCount,
        (j) => TextEditingController(text: weights[j].toString()),
      );

      // Update criteria controllers
      criteriaControllers = List.generate(
        critCount,
        (j) => TextEditingController(text: criteriaNames[j]),
      );

      // Update isBenefits
      this.isBenefits = List.from(isBenefits);
    });
    _notifyDataChanged();
  }

  void _updateFromExcelData(
    List<String> alternativeNames,
    List<String> criteriaNames,
    List<List<double>> matrix,
  ) {
    if (alternativeNames.isEmpty || criteriaNames.isEmpty || matrix.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data Excel tidak valid!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // Dispose old controllers
      for (var row in matrixControllers) {
        for (var controller in row) {
          controller.dispose();
        }
      }
      for (var controller in weightControllers) {
        controller.dispose();
      }
      for (var controller in alternativeControllers) {
        controller.dispose();
      }
      for (var controller in criteriaControllers) {
        controller.dispose();
      }

      // Update counts
      altCount = alternativeNames.length;
      critCount = criteriaNames.length;

      // Create new controllers for matrix
      matrixControllers = List.generate(
        altCount,
        (i) => List.generate(critCount, (j) {
          final value = matrix[i][j];
          return TextEditingController(text: value.toString());
        }),
      );

      // Create new controllers for weights (kosong)
      weightControllers = List.generate(
        critCount,
        (j) => TextEditingController(text: ''),
      );

      // Create new controllers for alternative names
      alternativeControllers = List.generate(
        altCount,
        (i) => TextEditingController(text: alternativeNames[i]),
      );

      // Create new controllers for criteria names
      criteriaControllers = List.generate(
        critCount,
        (j) => TextEditingController(text: criteriaNames[j]),
      );

      isBenefits = List.generate(critCount, (j) => true);
    });
    _notifyDataChanged();
  }

  void _addAlternative() {
    setState(() {
      altCount++;
      matrixControllers.add(
        List.generate(critCount, (j) => TextEditingController(text: '')),
      );
      alternativeControllers.add(
        TextEditingController(text: 'Alternatif $altCount'),
      );
    });
    _notifyDataChanged();
  }

  void _addCriteria() {
    setState(() {
      critCount++;
      for (int i = 0; i < altCount; i++) {
        matrixControllers[i].add(TextEditingController(text: ''));
      }
      weightControllers.add(TextEditingController(text: ''));
      isBenefits.add(true);
      criteriaControllers.add(
        TextEditingController(text: 'Kriteria $critCount'),
      );
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
      for (var controller in matrixControllers[index]) {
        controller.dispose();
      }
      matrixControllers.removeAt(index);
      alternativeControllers[index].dispose();
      alternativeControllers.removeAt(index);
    });
    _notifyDataChanged();
  }

  void _removeCriteria(int index) {
    if (critCount <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 2 kriteria'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    setState(() {
      critCount--;
      for (int i = 0; i < altCount; i++) {
        matrixControllers[i][index].dispose();
        matrixControllers[i].removeAt(index);
      }
      weightControllers[index].dispose();
      weightControllers.removeAt(index);
      isBenefits.removeAt(index);
      criteriaControllers[index].dispose();
      criteriaControllers.removeAt(index);
    });
    _notifyDataChanged();
  }

  void _clearAllValues() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Nilai?'),
        content: const Text(
          'Semua nilai matriks dan bobot akan dihapus. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performClearAllValues();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _performClearAllValues() {
    setState(() {
      for (int i = 0; i < altCount; i++) {
        for (int j = 0; j < critCount; j++) {
          matrixControllers[i][j].text = '';
        }
      }

      for (int j = 0; j < critCount; j++) {
        weightControllers[j].text = '';
      }

      for (int i = 0; i < altCount; i++) {
        alternativeControllers[i].text = 'Alternatif ${i + 1}';
      }

      for (int j = 0; j < critCount; j++) {
        criteriaControllers[j].text = 'Kriteria ${j + 1}';
      }
    });
    _notifyDataChanged();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua nilai dan nama berhasil direset'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _notifyDataChanged() {
    try {
      final matrix = List.generate(altCount, (i) {
        return List.generate(critCount, (j) {
          final text = matrixControllers[i][j].text;
          return text.isEmpty ? 0.0 : double.tryParse(text) ?? 0.0;
        });
      });

      final weights = List.generate(critCount, (j) {
        final text = weightControllers[j].text;
        return text.isEmpty ? 0.0 : double.tryParse(text) ?? 0.0;
      });

      final alternativeNames = alternativeControllers
          .map((c) => c.text)
          .toList();
      final criteriaNames = criteriaControllers.map((c) => c.text).toList();

      widget.onDataChanged(
        matrix: matrix,
        weights: weights,
        isBenefits: isBenefits,
        alternativeNames: alternativeNames,
        criteriaNames: criteriaNames,
      );
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tombol
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildButton(
              label: 'Tambah Alternatif',
              icon: Icons.add,
              color: Colors.blue,
              onPressed: _addAlternative,
            ),
            _buildButton(
              label: 'Tambah Kriteria',
              icon: Icons.add,
              color: Colors.green,
              onPressed: _addCriteria,
            ),
            _buildButton(
              label: 'Import Excel',
              icon: Icons.upload_file,
              color: Colors.purple,
              onPressed: _showExcelImportDialog,
            ),
            _buildButton(
              label: 'Hapus Semua Nilai',
              icon: Icons.clear_all,
              color: Colors.red,
              onPressed: _clearAllValues,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$altCount × $critCount',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth - 16;
            final bool isDesktop = screenWidth > 600;
            final double altColumnWidth = isDesktop ? 140 : 80;
            final double remainingWidth =
                availableWidth - altColumnWidth - (isDesktop ? 20 : 0);
            final double columnWidth = critCount > 0
                ? (remainingWidth / critCount).clamp(
                    isDesktop ? 80 : 50,
                    isDesktop ? 200 : 150,
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
                    child: _buildTable(
                      context,
                      isDark,
                      columnWidth,
                      altColumnWidth,
                      isDesktop,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        _buildWeightSection(context, isDark),
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

  // ... (rest of the code remains the same: _buildTable, _buildWeightSection, etc.)
  // Saya lanjutkan di bawah karena panjang...

  Widget _buildTable(
    BuildContext context,
    bool isDark,
    double columnWidth,
    double altColumnWidth,
    bool isDesktop,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              SizedBox(
                width: altColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Alternatif',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 12 : 9,
                    ),
                  ),
                ),
              ),
              ...List.generate(critCount, (j) {
                return SizedBox(
                  width: columnWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            criteriaControllers[j].text.isNotEmpty
                                ? criteriaControllers[j].text
                                : 'K${j + 1}',
                            style: TextStyle(
                              fontSize: isDesktop ? 11 : 8,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (critCount > 2)
                          GestureDetector(
                            onTap: () => _removeCriteria(j),
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
          ...List.generate(altCount, (i) {
            return Row(
              children: [
                SizedBox(
                  width: altColumnWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: alternativeControllers[i],
                            decoration: InputDecoration(
                              hintText: 'Alternatif ${i + 1}',
                              hintStyle: TextStyle(
                                fontSize: isDesktop ? 11 : 8,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: isDesktop ? 11 : 8,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                            onChanged: (_) => _notifyDataChanged(),
                          ),
                        ),
                        if (altCount > 2)
                          GestureDetector(
                            onTap: () => _removeAlternative(i),
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
                ...List.generate(critCount, (j) {
                  final text = matrixControllers[i][j].text;
                  final hasValue =
                      text.isNotEmpty &&
                      double.tryParse(text) != null &&
                      double.tryParse(text)! > 0;

                  return SizedBox(
                    width: columnWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: TextField(
                        controller: matrixControllers[i][j],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: '',
                          hintStyle: TextStyle(
                            fontSize: isDesktop ? 11 : 8,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                              color: hasValue
                                  ? Colors.green.withValues(alpha: 0.5)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                              color: hasValue
                                  ? Colors.green.withValues(alpha: 0.5)
                                  : Colors.grey[300]!,
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
                            horizontal: 6,
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

  Widget _buildWeightSection(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bobot & Jenis Kriteria',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 16 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          _buildButton(
            label: 'Import Kriteria',
            icon: Icons.upload_file,
            color: Colors.orange,
            onPressed: _showExcelCriteriaImportDialog,
          ),
          const SizedBox(height: 10),
          ...List.generate(critCount, (j) {
            final text = weightControllers[j].text;
            final hasWeight =
                text.isNotEmpty &&
                double.tryParse(text) != null &&
                double.tryParse(text)! > 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: isDesktop
                  ? _buildWeightRowDesktop(context, isDark, j, hasWeight)
                  : _buildWeightRowMobile(context, isDark, j, hasWeight),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeightRowDesktop(
    BuildContext context,
    bool isDark,
    int j,
    bool hasWeight,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            'K${j + 1}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.blue[300] : const Color(0xFF1A237E),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: criteriaControllers[j],
            decoration: InputDecoration(
              hintText: 'Nama Kriteria ${j + 1}',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: Color(0xFF1A237E),
                  width: 2,
                ),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onChanged: (_) => _notifyDataChanged(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: TextField(
            controller: weightControllers[j],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
            decoration: InputDecoration(
              hintText: 'Bobot',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: hasWeight
                      ? Colors.green.withValues(alpha: 0.5)
                      : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: hasWeight
                      ? Colors.green.withValues(alpha: 0.5)
                      : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: Color(0xFF1A237E),
                  width: 2,
                ),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              suffixText: '%',
              suffixStyle: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
            onChanged: (_) => _notifyDataChanged(),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[700] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Benefit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBenefits[j]
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isBenefits[j]
                      ? Colors.green[700]
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              Switch(
                value: isBenefits[j],
                onChanged: (value) {
                  setState(() {
                    isBenefits[j] = value;
                    _notifyDataChanged();
                  });
                },
                activeThumbColor: Colors.green,
                inactiveThumbColor: Colors.red,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                'Cost',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: !isBenefits[j]
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: !isBenefits[j]
                      ? Colors.red[700]
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightRowMobile(
    BuildContext context,
    bool isDark,
    int j,
    bool hasWeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                'K${j + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.blue[300] : const Color(0xFF1A237E),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: criteriaControllers[j],
                decoration: InputDecoration(
                  hintText: 'Nama Kriteria',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A237E),
                      width: 2,
                    ),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                onChanged: (_) => _notifyDataChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(width: 35),
            Expanded(
              flex: 2,
              child: TextField(
                controller: weightControllers[j],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                decoration: InputDecoration(
                  hintText: 'Bobot %',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: hasWeight
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: hasWeight
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A237E),
                      width: 2,
                    ),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                onChanged: (_) => _notifyDataChanged(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Benefit',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isBenefits[j]
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isBenefits[j]
                            ? Colors.green[700]
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                    Switch(
                      value: isBenefits[j],
                      onChanged: (value) {
                        setState(() {
                          isBenefits[j] = value;
                          _notifyDataChanged();
                        });
                      },
                      activeThumbColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(
                      'Cost',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: !isBenefits[j]
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: !isBenefits[j]
                            ? Colors.red[700]
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
