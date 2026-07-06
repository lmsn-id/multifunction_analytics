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
                        'Hasil Perankingan',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 20 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Terbaik: ${summary['Alternatif Terbaik']}',
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
                    'Skor: ${summary['Skor Terbaik']}',
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

            // Tabel Ranking
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
                          _buildHeaderCell('Out', isDesktop),
                          _buildHeaderCell('In', isDesktop),
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

                      Color? scoreColor;
                      final score = item['score'] as int? ?? 0;
                      if (score > 0) {
                        scoreColor = Colors.green;
                      } else if (score < 0) {
                        scoreColor = Colors.red;
                      } else {
                        scoreColor = Colors.grey;
                      }

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
                                '${item['rank']}',
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
                                '${item['outgoing']}',
                                isDesktop,
                                isDark,
                                isFirst: isFirst,
                              ),
                              _buildDataCell(
                                '${item['incoming']}',
                                isDesktop,
                                isDark,
                                isFirst: isFirst,
                              ),
                              _buildDataCell(
                                '${item['score']}',
                                isDesktop,
                                isDark,
                                isFirst: isFirst,
                                isBold: true,
                                textColor: scoreColor,
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
                final isBest = entry.key == 'Alternatif Terbaik';
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
                    '${entry.key}: ${entry.value}',
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

            // Detail Perhitungan
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
                  'Normalized',
                  resultData['normalized_matrix'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _detailMatrix(
                  context,
                  'Weighted',
                  resultData['weighted_matrix'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _detailMatrix(
                  context,
                  'Concordance',
                  resultData['concordance_matrix'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _detailMatrix(
                  context,
                  'Discordance',
                  resultData['discordance_matrix'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _detailMatrixInt(
                  context,
                  'Concordance Dominance',
                  resultData['concordance_dominance'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _detailMatrixInt(
                  context,
                  'Discordance Dominance',
                  resultData['discordance_dominance'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _detailMatrixInt(
                  context,
                  'Aggregate Dominance',
                  resultData['aggregate_dominance'],
                  isDesktop,
                ),
              ],
            ),

            // Thresholds
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  _buildChip(
                    'C: ${resultData['thresholds']['concordance'].toStringAsFixed(3)}',
                    Colors.blue,
                    isDesktop,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    'D: ${resultData['thresholds']['discordance'].toStringAsFixed(3)}',
                    Colors.red,
                    isDesktop,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EKSPOR EXCEL DENGAN STATUS ====================
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
        fileName: 'ELECTRE_Result',
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

  Widget _buildChip(String label, Color color, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12 : 6,
        vertical: isDesktop ? 6 : 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isDesktop ? 14 : 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // Detail Matrix (double)
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
                                value.toStringAsFixed(3),
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

  // Detail Matrix Integer (Dominance)
  Widget _detailMatrixInt(
    BuildContext context,
    String title,
    List<List<int>>? matrix,
    bool isDesktop,
  ) {
    if (matrix == null || matrix.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rows = matrix.length;
    final cols = matrix[0].length;

    final double cellWidth = isDesktop ? 80 : 55;
    final double labelWidth = isDesktop ? 50 : 30;
    final double fontSize = isDesktop ? 14 : 10;
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
                            return Container(
                              width: cellWidth,
                              padding: EdgeInsets.all(isDesktop ? 8 : 4),
                              decoration: BoxDecoration(
                                color: value == 1
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : null,
                                border: Border(
                                  right: BorderSide(
                                    color: isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[200]!,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: isDesktop ? 6 : 3,
                                ),
                                decoration: BoxDecoration(
                                  color: value == 1
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : null,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  value.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: value == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: value == 1
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                  ),
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
}
