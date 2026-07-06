// ahp_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/ahp_calculator.dart';
import '../widgets/ahp/input.dart';
import '../widgets/ahp/output.dart';

class AhpScreen extends StatefulWidget {
  const AhpScreen({super.key});

  @override
  State<AhpScreen> createState() => _AhpScreenState();
}

class _AhpScreenState extends State<AhpScreen>
    with SingleTickerProviderStateMixin {
  // Data input
  List<String> alternativeNames = [];
  List<String> criteriaNames = [];
  List<List<double>> criteriaMatrix = [];
  Map<String, List<List<double>>> alternativeMatrices = {};

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
    alternativeNames = ['Alternatif 1', 'Alternatif 2', 'Alternatif 3'];
    criteriaNames = ['Kriteria 1', 'Kriteria 2', 'Kriteria 3'];

    criteriaMatrix = [
      [1.0, 3.0, 5.0],
      [1 / 3, 1.0, 2.0],
      [1 / 5, 1 / 2, 1.0],
    ];

    alternativeMatrices = {
      'Kriteria 1': [
        [1.0, 3.0, 5.0],
        [1 / 3, 1.0, 2.0],
        [1 / 5, 1 / 2, 1.0],
      ],
      'Kriteria 2': [
        [1.0, 1 / 3, 1 / 5],
        [3.0, 1.0, 1 / 2],
        [5.0, 2.0, 1.0],
      ],
      'Kriteria 3': [
        [1.0, 2.0, 4.0],
        [1 / 2, 1.0, 3.0],
        [1 / 4, 1 / 3, 1.0],
      ],
    };

    errorMessage = null;
  }

  void _onDataChanged({
    required List<String> alternativeNames,
    required List<String> criteriaNames,
    required List<List<double>> criteriaMatrix,
    required Map<String, List<List<double>>> alternativeMatrices,
  }) {
    setState(() {
      this.alternativeNames = alternativeNames;
      this.criteriaNames = criteriaNames;
      this.criteriaMatrix = criteriaMatrix;
      this.alternativeMatrices = alternativeMatrices;
      hasResult = false;
      resultData = null;
      errorMessage = null;
    });
  }

  void _calculateAhp() async {
    setState(() {
      errorMessage = null;
    });

    if (alternativeNames.isEmpty || criteriaNames.isEmpty) {
      setState(() {
        errorMessage = 'Silakan isi alternatif dan kriteria terlebih dahulu';
      });
      return;
    }

    if (criteriaMatrix.isEmpty || criteriaMatrix[0].isEmpty) {
      setState(() {
        errorMessage = 'Silakan isi matriks perbandingan kriteria';
      });
      return;
    }

    for (final criterion in criteriaNames) {
      if (!alternativeMatrices.containsKey(criterion)) {
        setState(() {
          errorMessage = 'Matriks alternatif untuk "$criterion" belum diisi';
        });
        return;
      }
      final matrix = alternativeMatrices[criterion]!;
      if (matrix.isEmpty || matrix[0].isEmpty) {
        setState(() {
          errorMessage = 'Matriks alternatif untuk "$criterion" kosong';
        });
        return;
      }
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final result = AhpCalculator.calculate(
        alternatives: alternativeNames,
        criteria: criteriaNames,
        criteriaComparisonMatrix: criteriaMatrix,
        alternativeComparisonMatrices: alternativeMatrices,
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
                          child: InputAhpWidget(
                            alternativeNames: alternativeNames,
                            criteriaNames: criteriaNames,
                            criteriaMatrix: criteriaMatrix,
                            alternativeMatrices: alternativeMatrices,
                            onDataChanged: _onDataChanged,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

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
                              Text('Menghitung AHP...'),
                            ],
                          ),
                        ),
                      ),

                    if (hasResult && resultData != null)
                      RepaintBoundary(
                        child: ResultAhpCard(resultData: resultData!),
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
              maxLines: 3,
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
        onPressed: isLoading ? null : _calculateAhp,
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
                    'Hitung AHP',
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
        Icons.analytics,
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
      'AHP Method',
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
    );
  }
}

class _HeaderSubtitle extends StatelessWidget {
  const _HeaderSubtitle();

  @override
  Widget build(BuildContext context) {
    final screen = context.findAncestorStateOfType<_AhpScreenState>();
    final altLength = screen?.alternativeNames.length ?? 0;
    final critLength = screen?.criteriaNames.length ?? 0;

    return Text(
      '$altLength Alternatif × $critLength Kriteria',
      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
    );
  }
}
