import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/excel_service.dart';
import '../../services/web_file_picker.dart';
import 'table_selector.dart';

class ExcelImportCriteriaDialog extends StatefulWidget {
  final Function(
    List<String> criteriaNames,
    List<double> weights,
    List<bool> isBenefits,
  )
  onImport;

  const ExcelImportCriteriaDialog({super.key, required this.onImport});

  @override
  State<ExcelImportCriteriaDialog> createState() =>
      _ExcelImportCriteriaDialogState();
}

class _ExcelImportCriteriaDialogState extends State<ExcelImportCriteriaDialog> {
  List<List<dynamic>> _excelData = [];
  List<String> _headers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Range selection
  int _startRow = 0;
  int _endRow = 0;
  int _startCol = 0;
  int _endCol = 0;

  // Preview data
  List<List<dynamic>> _filteredData = [];
  final GlobalKey<TableSelectorState> _tableSelectorKey =
      GlobalKey<TableSelectorState>();

  @override
  void initState() {
    super.initState();
    _startRow = 0;
    _startCol = 0;
  }

  Future<void> _pickExcelFile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      Uint8List? fileBytes;

      if (kIsWeb) {
        try {
          fileBytes = await WebFilePicker.pickExcelFile();
        } catch (e) {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['xlsx', 'xls'],
            withData: true,
          );

          if (result == null || result.files.isEmpty) {
            setState(() => _isLoading = false);
            return;
          }

          final file = result.files.first;
          fileBytes = file.bytes;
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['xlsx', 'xls'],
          withData: true,
        );

        if (result == null || result.files.isEmpty) {
          setState(() => _isLoading = false);
          return;
        }

        final file = result.files.first;
        fileBytes = file.bytes;
      }

      if (fileBytes == null) {
        setState(() {
          _errorMessage = 'File tidak dapat dibaca';
          _isLoading = false;
        });
        return;
      }

      final data = await ExcelService.readExcel(fileBytes);

      if (data.isEmpty) {
        setState(() {
          _errorMessage = 'Data kosong';
          _isLoading = false;
        });
        return;
      }

      if (!ExcelService.isValidData(data)) {
        setState(() {
          _errorMessage =
              'Format data tidak valid. Pastikan ada header dan data.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _excelData = data;
        _headers = ExcelService.getHeaders(data);
        _endRow = data.length - 2;
        _endCol = _headers.length - 1;
        _filteredData = _getFilteredData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<List<dynamic>> _getFilteredData() {
    if (_excelData.isEmpty) return [];

    final filtered = <List<dynamic>>[];

    try {
      if (_startCol <= _endCol && _startCol < _excelData[0].length) {
        final endCol = _endCol < _excelData[0].length
            ? _endCol
            : _excelData[0].length - 1;
        final headerRow = _excelData[0].sublist(_startCol, endCol + 1);
        filtered.add(headerRow);
      }

      final dataRows = _excelData.sublist(1);
      final endRow = _endRow < dataRows.length ? _endRow : dataRows.length - 1;

      for (int i = _startRow; i <= endRow && i < dataRows.length; i++) {
        if (i < dataRows.length && _startCol < dataRows[i].length) {
          final endCol = _endCol < dataRows[i].length
              ? _endCol
              : dataRows[i].length - 1;
          final row = dataRows[i].sublist(_startCol, endCol + 1);
          filtered.add(row);
        }
      }
    } catch (e) {
      debugPrint('Error in _getFilteredData: $e');
      return [];
    }

    return filtered;
  }

  void _updateSelection(int startRow, int endRow, int startCol, int endCol) {
    setState(() {
      _startRow = startRow;
      _endRow = endRow;
      _startCol = startCol;
      _endCol = endCol;
      _filteredData = _getFilteredData();
    });
  }

  void _confirmImport() {
    try {
      if (_filteredData.isEmpty || _filteredData.length < 2) {
        setState(() {
          _errorMessage = 'Tidak ada data yang dipilih untuk diimport';
        });
        return;
      }

      // Parse data untuk kriteria
      final headers = _filteredData[0];
      final rows = _filteredData.sublist(1);

      final criteriaNames = <String>[];
      final weights = <double>[];
      final isBenefits = <bool>[];

      // Deteksi kolom berdasarkan header
      int nameCol = -1;
      int weightCol = -1;
      int typeCol = -1;

      for (int i = 0; i < headers.length; i++) {
        final header = headers[i]?.toString().toLowerCase() ?? '';
        if (header.contains('nama') ||
            header.contains('kriteria') ||
            header.contains('criteria')) {
          nameCol = i;
        } else if (header.contains('bobot') ||
            header.contains('weight') ||
            header.contains('%')) {
          weightCol = i;
        } else if (header.contains('atribut') ||
            header.contains('type') ||
            header.contains('benefit') ||
            header.contains('cost')) {
          typeCol = i;
        }
      }

      // Jika tidak ditemukan, gunakan default: col 0 = nama, col 1 = bobot, col 2 = atribut
      if (nameCol == -1) nameCol = 0;
      if (weightCol == -1) weightCol = 1;
      if (typeCol == -1) typeCol = 2;

      for (var row in rows) {
        final name = row[nameCol]?.toString().trim() ?? '';
        if (name.isNotEmpty) {
          criteriaNames.add(name);

          final weightStr = row[weightCol]?.toString().trim() ?? '';
          double weight = 0;
          if (weightStr.isNotEmpty) {
            String cleanWeight = weightStr.replaceAll('%', '').trim();
            cleanWeight = cleanWeight.replaceAll(',', '.');

            final parsed = double.tryParse(cleanWeight);
            if (parsed != null) {
              if (parsed <= 1) {
                weight = parsed * 100;
              } else {
                weight = parsed;
              }
            } else {
              weight = 0;
            }
          }
          weights.add(weight);

          final typeStr = row[typeCol]?.toString().toLowerCase().trim() ?? '';
          final isBenefit =
              typeStr.contains('benefit') ||
              typeStr == 'benefit' ||
              typeStr == 'b' ||
              typeStr.contains('keuntungan') ||
              typeStr == 'benefit' ||
              typeStr == 'keuntungan';
          isBenefits.add(isBenefit);
        }
      }

      if (criteriaNames.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ada data kriteria yang valid';
        });
        return;
      }

      widget.onImport(criteriaNames, weights, isBenefits);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isDesktop ? screenSize.width * 0.85 : screenSize.width * 0.92,
        height: isDesktop ? screenSize.height * 0.85 : screenSize.height * 0.9,
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1000 : double.infinity,
          maxHeight: isDesktop ? 800 : double.infinity,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.upload_file, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Import Kriteria dari Excel',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Content - Gunakan Expanded agar mengisi ruang
            Expanded(
              child: _excelData.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Upload file Excel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Support .xlsx dan .xls',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 24),
                            if (_isLoading)
                              const CircularProgressIndicator()
                            else
                              ElevatedButton.icon(
                                onPressed: _pickExcelFile,
                                icon: const Icon(Icons.upload),
                                label: Text(
                                  kIsWeb ? 'Pilih File' : 'Pilih File Excel',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table Selector - Langsung pakai Expanded
                        Expanded(
                          child: TableSelector(
                            key: _tableSelectorKey,
                            data: _excelData.sublist(1),
                            headers: _headers,
                            onSelectionChanged: _updateSelection,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _excelData = [];
                                  _headers = [];
                                  _filteredData = [];
                                  _startRow = 0;
                                  _startCol = 0;
                                  _endRow = 0;
                                  _endCol = 0;
                                });
                                _tableSelectorKey.currentState
                                    ?.resetSelection();
                              },
                              child: const Text('Reset'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _filteredData.length > 1
                                  ? _confirmImport
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Import Data'),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
