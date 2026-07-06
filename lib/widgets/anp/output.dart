// output.dart (widgets/anp/output.dart)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultAnpCard extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultAnpCard({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    final rankings = resultData['rankings'] as List;
    final summary = resultData['summary'] as Map;
    final List<String> nodeLabels = (resultData['node_labels'] as List)
        .cast<String>();

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
                        'Hasil Perankingan ANP',
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
                    'Skor: ${(summary['skor_terbaik'] as double).toStringAsFixed(4)}',
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

            // Status Konsistensi
            _buildConsistencyStatus(context, summary, isDesktop, isDark),
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
                          _buildHeaderCell('Prioritas', isDesktop),
                        ],
                      ),
                    ),
                    // Data rows
                    ...List.generate(rankings.length, (index) {
                      final item = rankings[index];
                      final isFirst = index == 0;
                      final isLast = index == rankings.length - 1;
                      final isEven = index % 2 == 0;

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
                                (item['priority'] as double).toStringAsFixed(4),
                                isDesktop,
                                isDark,
                                isFirst: isFirst,
                                isBold: isFirst,
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
                    '${_formatLabel(entry.key)}: $displayValue',
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
                _buildDetailSection(
                  context,
                  'Analisis Kriteria',
                  resultData['criteria_analysis'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _buildAlternativeDetails(
                  context,
                  'Analisis Alternatif',
                  resultData['alternative_analysis'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _buildInnerDependenceDetails(
                  context,
                  'Inner Dependence',
                  resultData['inner_dependence_analysis'],
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _buildMatrixDetail(
                  context,
                  'Unweighted Supermatrix',
                  resultData['unweighted_supermatrix'],
                  nodeLabels,
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _buildMatrixDetail(
                  context,
                  'Weighted Supermatrix',
                  resultData['weighted_supermatrix'],
                  nodeLabels,
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _buildMatrixDetail(
                  context,
                  'Limit Supermatrix',
                  resultData['limit_supermatrix'],
                  nodeLabels,
                  isDesktop,
                ),
                const SizedBox(height: 8),
                _buildGlobalPriority(
                  context,
                  'Global Priority',
                  resultData['global_priority'],
                  nodeLabels,
                  isDesktop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyStatus(
    BuildContext context,
    Map summary,
    bool isDesktop,
    bool isDark,
  ) {
    final isConsistent = summary['status_konsistensi'].toString().contains(
      'Konsisten',
    );
    final cr = (summary['consistency_ratio'] as double?) ?? 0;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 12 : 8),
      decoration: BoxDecoration(
        color: isConsistent
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConsistent
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConsistent ? Icons.check_circle : Icons.warning,
            color: isConsistent ? Colors.green : Colors.red,
            size: isDesktop ? 24 : 18,
          ),
          SizedBox(width: isDesktop ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consistency Ratio: ${cr.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 11,
                    fontWeight: FontWeight.w600,
                    color: isConsistent ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                Text(
                  summary['status_konsistensi'],
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 9,
                    color: isConsistent ? Colors.green[600] : Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, bool isDesktop) {
    final width = isDesktop ? 150.0 : 80.0;
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
    final width = isDesktop ? 150.0 : 80.0;
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

  String _formatLabel(String key) {
    final map = {
      'jumlah_alternatif': 'Jumlah Alternatif',
      'jumlah_kriteria': 'Jumlah Kriteria',
      'lambda_max': 'λmax',
      'consistency_index': 'CI',
      'consistency_ratio': 'CR',
      'status_konsistensi': 'Status Konsistensi',
      'alternatif_terbaik': 'Alternatif Terbaik',
      'skor_terbaik': 'Skor Terbaik',
      'limit_supermatrix_konvergen': 'Limit Supermatrix Konvergen',
      'jumlah_iterasi': 'Jumlah Iterasi',
    };
    return map[key] ?? key;
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
    bool isDesktop,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();

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
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('λmax', data['lambda_max'], isDesktop),
                _buildDetailRow('CI', data['consistency_index'], isDesktop),
                _buildDetailRow('CR', data['consistency_ratio'], isDesktop),
                _buildDetailRow('RI', data['random_index'], isDesktop),
                _buildDetailRow(
                  'Status',
                  data['is_consistent'] ? '✓ Konsisten' : '✗ Tidak Konsisten',
                  isDesktop,
                  isConsistent: data['is_consistent'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    dynamic value,
    bool isDesktop, {
    bool? isConsistent,
  }) {
    if (value == null) return const SizedBox.shrink();

    String displayValue = value.toString();
    if (value is double) {
      displayValue = value.toStringAsFixed(4);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: isDesktop ? 60 : 40,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? 12 : 9,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: isDesktop ? 12 : 9,
                fontWeight: isConsistent != null
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isConsistent != null
                    ? (isConsistent ? Colors.green[700] : Colors.red[700])
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeDetails(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
    bool isDesktop,
  ) {
    if (data.isEmpty || data.containsKey('note')) {
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data['note'] ?? 'Tidak ada data',
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 9,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

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
          ...data.entries.map((entry) {
            final criterion = entry.key;
            final detail = entry.value as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(isDesktop ? 12 : 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kriteria: $criterion',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 13 : 9,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDetailRow('λmax', detail['lambda_max'], isDesktop),
                  _buildDetailRow('CI', detail['consistency_index'], isDesktop),
                  _buildDetailRow('CR', detail['consistency_ratio'], isDesktop),
                  _buildDetailRow(
                    'Status',
                    detail['is_consistent']
                        ? '✓ Konsisten'
                        : '✗ Tidak Konsisten',
                    isDesktop,
                    isConsistent: detail['is_consistent'],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Priority Vector:',
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildPriorityVector(
                    detail['priority_vector'] as List<double>,
                    isDesktop,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInnerDependenceDetails(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
    bool isDesktop,
  ) {
    if (data.isEmpty || data.containsKey('note')) {
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data['note'] ?? 'Tidak ada inner dependence',
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 9,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

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
          ...data.entries.map((entry) {
            final criterion = entry.key;
            final detail = entry.value as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(isDesktop ? 12 : 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaruh terhadap: $criterion',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 13 : 9,
                      color: Colors.orange[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDetailRow('λmax', detail['lambda_max'], isDesktop),
                  _buildDetailRow('CI', detail['consistency_index'], isDesktop),
                  _buildDetailRow('CR', detail['consistency_ratio'], isDesktop),
                  _buildDetailRow(
                    'Status',
                    detail['is_consistent']
                        ? '✓ Konsisten'
                        : '✗ Tidak Konsisten',
                    isDesktop,
                    isConsistent: detail['is_consistent'],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Priority Vector:',
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildPriorityVector(
                    detail['priority_vector'] as List<double>,
                    isDesktop,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriorityVector(List<double> vector, bool isDesktop) {
    return Wrap(
      spacing: 8,
      children: vector.asMap().entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'A${entry.key + 1}: ${entry.value.toStringAsFixed(4)}',
            style: TextStyle(
              fontSize: isDesktop ? 11 : 8,
              color: Colors.blue[700],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMatrixDetail(
    BuildContext context,
    String title,
    List<List<double>> matrix,
    List<String> labels,
    bool isDesktop,
  ) {
    if (matrix.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rows = matrix.length;
    final cols = matrix[0].length;

    final double cellWidth = isDesktop ? 80 : 55;
    final double labelWidth = isDesktop ? 60 : 40;
    final double fontSize = isDesktop ? 11 : 7;

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
                  // Header
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
                              fontSize: isDesktop ? 11 : 8,
                              color: isDark ? Colors.white : Colors.blue[800],
                            ),
                          ),
                        ),
                        ...List.generate(cols, (j) {
                          final label = labels.isNotEmpty && j < labels.length
                              ? labels[j]
                              : 'N${j + 1}';
                          return Container(
                            width: cellWidth,
                            padding: EdgeInsets.all(isDesktop ? 8 : 4),
                            child: Text(
                              label.length > 6 ? label.substring(0, 6) : label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 10 : 7,
                                color: isDark ? Colors.white : Colors.blue[800],
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  // Data rows
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
                              labels.isNotEmpty && i < labels.length
                                  ? (labels[i].length > 6
                                        ? labels[i].substring(0, 6)
                                        : labels[i])
                                  : 'N${i + 1}',
                              style: TextStyle(
                                fontSize: isDesktop ? 10 : 7,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
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

  Widget _buildGlobalPriority(
    BuildContext context,
    String title,
    List<double> priority,
    List<String> labels,
    bool isDesktop,
  ) {
    if (priority.isEmpty) return const SizedBox.shrink();

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
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: priority.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final label = labels.isNotEmpty && index < labels.length
                    ? labels[index]
                    : 'N${index + 1}';
                final isAlternative = index >= (labels.length / 2).floor();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAlternative
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isAlternative
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$label: ${value.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : 9,
                      fontWeight: isAlternative ? FontWeight.bold : null,
                      color: isAlternative
                          ? Colors.green[700]
                          : Colors.blue[700],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
