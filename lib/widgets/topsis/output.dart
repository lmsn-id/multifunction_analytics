// widgets/topsis/output.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/excel_export_service.dart';

class ResultCard extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultCard({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    final rankings = resultData['rankings'] as List;
    final summary = resultData['summary'] as Map;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 20 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 12 : 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.green,
                    size: isDesktop ? 28 : 16,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil Perankingan TOPSIS',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 20 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Terbaik: ${summary['alternatif_terbaik']}',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 16 : 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : 6,
                    vertical: isDesktop ? 8 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Skor: ${summary['skor_terbaik']?.toStringAsFixed(4) ?? 0}',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tombol Download Excel
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _exportToExcel(context),
                icon: const Icon(Icons.download),
                label: const Text('Download Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tabel Ranking TOPSIS
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 10,
                        vertical: isDesktop ? 12 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildHeaderCell('Rank', isDesktop),
                          _buildHeaderCell('Alternatif', isDesktop),
                          _buildHeaderCell('Score', isDesktop),
                        ],
                      ),
                    ),
                    // Data rows
                    ...List.generate(rankings.length, (index) {
                      final item = rankings[index];
                      final isFirst = index == 0;
                      final isLast = index == rankings.length - 1;
                      final isEven = index % 2 == 0;

                      final score = item['score'] as double? ?? 0.0;

                      return ClipRRect(
                        borderRadius: isLast
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              )
                            : BorderRadius.zero,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 16 : 10,
                            vertical: isDesktop ? 12 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: isFirst
                                ? Colors.green.withValues(alpha: 0.15)
                                : (isEven
                                      ? (isDark
                                            ? Colors.grey[850]
                                            : Colors.grey[50])
                                      : (isDark
                                            ? Colors.grey[900]
                                            : Colors.white)),
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                      color: isDark
                                          ? Colors.grey[700]!
                                          : Colors.grey[200]!,
                                      width: 0.5,
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              _buildDataCell(
                                '${index + 1}',
                                isDesktop,
                                isDark,
                                isFirst: isFirst,
                                isBold: isFirst,
                              ),
                              _buildDataCell(
                                item['alternative'] ?? '',
                                isDesktop,
                                isDark,
                                isFirst: isFirst,
                                isBold: isFirst,
                              ),
                              _buildDataCell(
                                score.toStringAsFixed(4),
                                isDesktop,
                                isDark,
                                isFirst: isFirst,
                                isBold: true,
                                textColor: isFirst ? Colors.green : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary
            Wrap(
              spacing: isDesktop ? 12 : 6,
              runSpacing: isDesktop ? 8 : 4,
              children: summary.entries.map((entry) {
                final isBest = entry.key == 'alternatif_terbaik';
                String displayKey = entry.key;
                if (entry.key == 'metode')
                  displayKey = 'Metode';
                else if (entry.key == 'jumlah_alternatif')
                  displayKey = 'Jumlah Alternatif';
                else if (entry.key == 'jumlah_kriteria')
                  displayKey = 'Jumlah Kriteria';
                else if (entry.key == 'alternatif_terbaik')
                  displayKey = 'Alternatif Terbaik';
                else if (entry.key == 'skor_terbaik')
                  displayKey = 'Skor Terbaik';

                String displayValue = entry.value.toString();
                if (entry.value is double) {
                  displayValue = (entry.value as double).toStringAsFixed(4);
                }

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : 8,
                    vertical: isDesktop ? 8 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: isBest
                        ? Colors.green.withValues(alpha: 0.15)
                        : (isDark ? Colors.grey[800] : Colors.grey[50]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBest
                          ? Colors.green
                          : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      width: isBest ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '$displayKey: $displayValue',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 14 : 10,
                      fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                      color: isBest
                          ? Colors.green[700]
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Detail Perhitungan TOPSIS
            ExpansionTile(
              title: Text(
                'Detail Perhitungan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: isDesktop ? 16 : 12,
                ),
              ),
              leading: Icon(
                Icons.table_chart,
                color: Theme.of(context).primaryColor,
                size: isDesktop ? 24 : 18,
              ),
              children: [
                _detailMatrix(
                  context,
                  'Normalized Matrix',
                  resultData['normalized_matrix'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _detailMatrix(
                  context,
                  'Weighted Matrix',
                  resultData['weighted_matrix'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _detailVector(
                  context,
                  'Ideal Positive (A+)',
                  resultData['ideal_positive'],
                  isDesktop,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _detailVector(
                  context,
                  'Ideal Negative (A-)',
                  resultData['ideal_negative'],
                  isDesktop,
                  Colors.red,
                ),
                const SizedBox(height: 8),
                _detailDistances(
                  context,
                  'Distances',
                  resultData['distances'],
                  isDesktop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PERBAIKAN EKSPOR EXCEL ====================
  // Fungsi export yang sudah diperbaiki
  Future<void> _exportToExcel(BuildContext context) async {
    // PERBAIKAN: Gunakan dialog yang lebih informatif dengan pesan progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('⏳ Menyimpan file Excel...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final exportData = Map<String, dynamic>.from(resultData);

      if (exportData.isEmpty) {
        throw Exception('Data kosong tidak dapat diexport');
      }

      // PERBAIKAN: Gunakan exportToExcelWithStatus
      final result = await ExcelExportService.exportToExcelWithStatus(
        exportData,
        fileName: 'TOPSIS_Result_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );

      if (context.mounted) {
        Navigator.pop(context); // Tutup loading dialog
      }

      if (context.mounted) {
        // PERBAIKAN: Tampilkan pesan yang lebih jelas
        switch (result) {
          case ExportResult.success:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '✅ File Excel berhasil disimpan di folder Download!',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            break;
          case ExportResult.cancelled:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⏹️ Penyimpanan dibatalkan oleh pengguna'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
            break;
          case ExportResult.error:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Gagal menyimpan file. Silakan coba lagi.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
            break;
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ==================== WIDGET PEMBANTU ====================
  Widget _buildHeaderCell(String text, bool isDesktop) {
    final width = isDesktop ? 100.0 : 60.0;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isDesktop ? 14 : 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(
    String text,
    bool isDesktop,
    bool isDark, {
    bool isFirst = false,
    bool isBold = false,
    Color? textColor,
  }) {
    final width = isDesktop ? 100.0 : 60.0;
    Color finalColor = textColor ?? (isDark ? Colors.white : Colors.black87);

    if (isFirst && textColor == null) {
      finalColor = isDark ? Colors.white : Colors.green.shade700;
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: isDesktop ? 16 : 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: finalColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _detailMatrix(
    BuildContext context,
    String title,
    List<List<double>>? matrix,
    bool isDesktop,
  ) {
    if (matrix == null || matrix.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rows = matrix.length;
    final cols = matrix[0].length;

    final double cellWidth = isDesktop ? 80 : 55;
    final double labelWidth = isDesktop ? 50 : 30;
    final double fontSize = isDesktop ? 12 : 8;
    final double headerFontSize = isDesktop ? 12 : 8;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 15 : 10,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Container(
                    color: isDark ? Colors.grey[800] : Colors.blue[50],
                    child: Row(
                      children: [
                        Container(
                          width: labelWidth,
                          padding: EdgeInsets.all(isDesktop ? 8 : 4),
                          child: Text(
                            '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: headerFontSize,
                              color: isDark ? Colors.white : Colors.blue[800],
                            ),
                          ),
                        ),
                        ...List.generate(cols, (j) {
                          return Container(
                            width: cellWidth,
                            padding: EdgeInsets.all(isDesktop ? 8 : 4),
                            child: Text(
                              'K${j + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: headerFontSize,
                                color: isDark ? Colors.white : Colors.blue[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  ...List.generate(rows, (i) {
                    return Container(
                      color: i % 2 == 0
                          ? (isDark ? Colors.grey[850] : Colors.grey[50])
                          : (isDark ? Colors.grey[900] : Colors.white),
                      child: Row(
                        children: [
                          Container(
                            width: labelWidth,
                            padding: EdgeInsets.all(isDesktop ? 8 : 4),
                            child: Text(
                              'A${i + 1}',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          ...List.generate(cols, (j) {
                            final value = matrix[i][j];
                            Color? cellColor;
                            if (value > 0.5) {
                              cellColor = Colors.green.withValues(alpha: 0.3);
                            } else if (value > 0.3) {
                              cellColor = Colors.orange.withValues(alpha: 0.2);
                            } else if (value > 0) {
                              cellColor = Colors.red.withValues(alpha: 0.15);
                            }

                            return Container(
                              width: cellWidth,
                              padding: EdgeInsets.all(isDesktop ? 8 : 4),
                              decoration: BoxDecoration(
                                color: cellColor,
                                border: Border(
                                  right: BorderSide(
                                    color: isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[200]!,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                value.toStringAsFixed(4),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: value > 0.5
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailVector(
    BuildContext context,
    String title,
    List<double>? vector,
    bool isDesktop,
    Color color,
  ) {
    if (vector == null || vector.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 15 : 10,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Wrap(
              spacing: isDesktop ? 16 : 8,
              runSpacing: 4,
              children: List.generate(vector.length, (j) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'K${j + 1}:',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 9,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vector[j].toStringAsFixed(4),
                      style: TextStyle(
                        fontSize: isDesktop ? 14 : 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailDistances(
    BuildContext context,
    String title,
    List<Map<String, double>>? distances,
    bool isDesktop,
  ) {
    if (distances == null || distances.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 15 : 10,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Column(
              children: List.generate(distances.length, (i) {
                final dPos = distances[i]['positive'] ?? 0;
                final dNeg = distances[i]['negative'] ?? 0;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 4 : 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'A${i + 1}:',
                        style: TextStyle(
                          fontSize: isDesktop ? 13 : 9,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 12 : 6,
                          vertical: isDesktop ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'D+ = ${dPos.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 12 : 6,
                          vertical: isDesktop ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'D- = ${dNeg.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
