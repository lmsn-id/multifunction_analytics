import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/electre_calculator.dart';
import '../widgets/electre/input.dart';
import '../widgets/electre/output.dart';

class ElectreScreen extends StatefulWidget {
  const ElectreScreen({super.key});

  @override
  State<ElectreScreen> createState() => _ElectreScreenState();
}

class _ElectreScreenState extends State<ElectreScreen>
    with SingleTickerProviderStateMixin {
  // Data input
  List<List<double>> decisionMatrix = [];
  List<double> weights = [];
  List<bool> isBenefits = [];
  List<String> alternativeNames = [];
  List<String> criteriaNames = [];

  // Status
  bool isLoading = false;
  bool hasResult = false;
  Map<String, dynamic>? resultData;
  String? errorMessage;

  // Controller untuk scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeDefaultData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeDefaultData() {
    alternativeNames = [
      'Alternatif 1',
      'Alternatif 2',
      'Alternatif 3',
      'Alternatif 4',
    ];

    criteriaNames = ['Kriteria 1', 'Kriteria 2', 'Kriteria 3', 'Kriteria 4'];
    weights = [0.0, 0.0, 0.0, 0.0];
    isBenefits = [true, true, true, true];
    decisionMatrix = [
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
    ];
    errorMessage = null;
  }

  void _onDataChanged({
    required List<List<double>> matrix,
    required List<double> weights,
    required List<bool> isBenefits,
    required List<String> alternativeNames,
    required List<String> criteriaNames,
  }) {
    setState(() {
      decisionMatrix = matrix;
      this.weights = weights;
      this.isBenefits = isBenefits;
      this.alternativeNames = alternativeNames;
      this.criteriaNames = criteriaNames;
      hasResult = false;
      resultData = null;
      errorMessage = null;
    });
  }

  void _calculateElectre() async {
    setState(() {
      errorMessage = null;
    });

    if (decisionMatrix.isEmpty || decisionMatrix[0].isEmpty) {
      setState(() {
        errorMessage = 'Silakan isi matriks keputusan terlebih dahulu';
      });
      return;
    }

    bool hasEmpty = false;
    for (var row in decisionMatrix) {
      for (var val in row) {
        if (val == 0) {
          hasEmpty = true;
          break;
        }
      }
      if (hasEmpty) break;
    }

    if (hasEmpty) {
      setState(() {
        errorMessage =
            '⚠️ Masih ada nilai 0 pada matriks. Silakan isi semua nilai.';
      });
      return;
    }

    double totalWeight = weights.fold(0.0, (a, b) => a + b);
    if (totalWeight != 100) {
      setState(() {
        errorMessage =
            '⚠️ Total bobot ${totalWeight.toStringAsFixed(1)}% (harus 100%)';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final result = ElectreCalculator.calculate(
        decisionMatrix,
        weights.map((e) => e / 100).toList(),
        isBenefits,
        alternativeNames,
      );

      if (mounted) {
        setState(() {
          resultData = result;
          hasResult = true;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
          hasResult = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = [
      Theme.of(context).primaryColor.withValues(alpha: 0.04),
      Theme.of(context).scaffoldBackgroundColor,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Column(
        children: [
          if (errorMessage != null) _buildErrorMessage(context),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              // Tambahkan padding bottom untuk memberi ruang bottom nav
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context, isDark),
                    const SizedBox(height: 12),

                    RepaintBoundary(
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: InputMatrixWidget(
                            initialMatrix: decisionMatrix,
                            alternativeNames: alternativeNames,
                            criteriaNames: criteriaNames,
                            initialWeights: weights,
                            initialIsBenefits: isBenefits,
                            onDataChanged: _onDataChanged,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildWeightInfo(context, isDark),
                    const SizedBox(height: 8),

                    _buildCalculateButton(context),
                    const SizedBox(height: 12),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text('Menghitung ELECTRE...'),
                            ],
                          ),
                        ),
                      ),

                    if (hasResult && resultData != null)
                      RepaintBoundary(
                        child: ResultCard(resultData: resultData!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDark) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _HeaderIcon(),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_HeaderTitle(), _HeaderSubtitle()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfo(BuildContext context, bool isDark) {
    double totalWeight = weights.fold(0.0, (a, b) => a + b);
    final isWeightValid = totalWeight == 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14),
          const SizedBox(width: 6),
          Text(
            'Total Bobot: ${totalWeight.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isWeightValid ? Colors.green[700] : Colors.grey[600],
            ),
          ),
          if (!isWeightValid)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                '(harus 100%)',
                style: TextStyle(fontSize: 10, color: Colors.orange[700]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(bottom: BorderSide(color: Colors.red.shade300)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _calculateElectre,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Hitung ELECTRE',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.calculate_outlined,
        color: Theme.of(context).primaryColor,
        size: 18,
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'ELECTRE Method',
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
    );
  }
}

class _HeaderSubtitle extends StatelessWidget {
  const _HeaderSubtitle();

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorStateOfType<_ElectreScreenState>();
    final length = screen?.decisionMatrix.length ?? 0;
    final critLength = screen?.decisionMatrix.isNotEmpty == true
        ? screen!.decisionMatrix[0].length
        : 0;

    return Text(
      '$length Alternatif × $critLength Kriteria',
      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
    );
  }
}
