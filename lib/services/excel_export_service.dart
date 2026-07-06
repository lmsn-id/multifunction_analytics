import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

enum ExportResult { success, cancelled, error }

class ExcelExportService {
  static CellValue? _cell(dynamic value) {
    if (value == null) return null;
    if (value is CellValue) return value;
    if (value is String) return TextCellValue(value);
    if (value is int) return IntCellValue(value);
    if (value is double) return DoubleCellValue(value);
    if (value is bool) return BoolCellValue(value);
    if (value is DateTime) {
      return DateCellValue(
        year: value.year,
        month: value.month,
        day: value.day,
      );
    }
    return TextCellValue(value.toString());
  }

  // ==================== METHOD UTAMA ====================
  static Future<bool> exportToExcel(
    Map<String, dynamic> data, {
    String? fileName,
  }) async {
    try {
      final excel = Excel.createExcel();

      final List<String> sheetOrder = [
        'rankings',
        'summary',
        'normalized_matrix',
        'weighted_matrix',
        'ideal_positive',
        'ideal_negative',
        'distances',
      ];

      bool hasData = false;

      for (var key in sheetOrder) {
        if (data.containsKey(key)) {
          final value = data[key];
          if (value != null) {
            final sheet = excel[_formatSheetName(key)];
            _addDataToSheet(sheet, value, key);
            hasData = true;
          }
        }
      }

      for (var entry in data.entries) {
        if (!sheetOrder.contains(entry.key)) {
          final value = entry.value;
          if (value != null) {
            final sheet = excel[_formatSheetName(entry.key)];
            _addDataToSheet(sheet, value, entry.key);
            hasData = true;
          }
        }
      }

      if (!hasData) {
        debugPrint('Tidak ada data untuk diexport');
        return false;
      }

      final bytes = excel.encode();
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Gagal mengencode file Excel');
      }

      return await _saveFile(
        bytes,
        fileName ?? 'SPK_Result_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      debugPrint('Error exporting Excel: $e');
      return false;
    }
  }

  // ==================== METHOD DENGAN STATUS ====================
  static Future<ExportResult> exportToExcelWithStatus(
    Map<String, dynamic> data, {
    String? fileName,
  }) async {
    try {
      final excel = Excel.createExcel();

      final List<String> sheetOrder = [
        'rankings',
        'summary',
        'normalized_matrix',
        'weighted_matrix',
        'ideal_positive',
        'ideal_negative',
        'distances',
      ];

      bool hasData = false;

      for (var key in sheetOrder) {
        if (data.containsKey(key)) {
          final value = data[key];
          if (value != null) {
            final sheet = excel[_formatSheetName(key)];
            _addDataToSheet(sheet, value, key);
            hasData = true;
          }
        }
      }

      for (var entry in data.entries) {
        if (!sheetOrder.contains(entry.key)) {
          final value = entry.value;
          if (value != null) {
            final sheet = excel[_formatSheetName(entry.key)];
            _addDataToSheet(sheet, value, entry.key);
            hasData = true;
          }
        }
      }

      if (!hasData) {
        return ExportResult.error;
      }

      final bytes = excel.encode();
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Gagal mengencode file Excel');
      }

      return await _saveFileWithStatus(
        bytes,
        fileName ?? 'SPK_Result_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      debugPrint('Error exporting Excel: $e');
      return ExportResult.error;
    }
  }

  static void _addDataToSheet(Sheet sheet, dynamic value, String key) {
    if (value is List) {
      if (value.isEmpty) {
        sheet.appendRow([_cell('Data kosong')]);
        return;
      }

      if (value.first is Map) {
        _addListMapToSheet(sheet, value.cast<Map>(), key);
      } else if (value.first is List) {
        final firstRow = value.first as List;
        if (firstRow.isEmpty) {
          _addListToSheet(sheet, value);
          return;
        }
        final firstElement = firstRow.first;
        if (firstElement is double) {
          _addDoubleMatrixToSheet(sheet, value.cast<List<dynamic>>(), key);
        } else if (firstElement is int) {
          _addIntMatrixToSheet(sheet, value.cast<List<dynamic>>(), key);
        } else if (firstElement is num) {
          try {
            _addDoubleMatrixToSheet(sheet, value.cast<List<dynamic>>(), key);
          } catch (e) {
            _addListToSheet(sheet, value);
          }
        } else {
          _addListToSheet(sheet, value);
        }
      } else {
        _addListToSheet(sheet, value);
      }
    } else if (value is Map) {
      _addMapToSheet(sheet, value, key);
    } else {
      sheet.appendRow([_cell(key), _cell(value)]);
    }
  }

  static String _formatSheetName(String key) {
    String name = key.replaceAll('_', ' ');
    List<String> words = name.split(' ');
    words = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).toList();
    String result = words.join(' ');
    if (result.length > 31) result = result.substring(0, 31);
    return result.isEmpty ? 'Sheet' : result;
  }

  // ==================== LIST MAP (RANKINGS) - TANPA STYLE ====================
  static void _addListMapToSheet(Sheet sheet, List<Map> data, String title) {
    if (data.isEmpty) return;

    // Judul
    sheet.appendRow([_cell(title.toUpperCase())]);
    // Spacer
    sheet.appendRow([]);
    // Header
    final headers = data.first.keys.toList();
    sheet.appendRow(headers.map((h) => _cell(h.toString())).toList());

    // Data rows
    for (var item in data) {
      final row = <CellValue?>[];
      for (var key in headers) {
        final value = item[key];
        if (value is double) {
          row.add(_cell(value.toStringAsFixed(4)));
        } else if (value is int) {
          row.add(_cell(value.toString()));
        } else {
          row.add(_cell(value?.toString() ?? ''));
        }
      }
      sheet.appendRow(row);
    }
  }

  // ==================== DOUBLE MATRIX - TANPA STYLE ====================
  static void _addDoubleMatrixToSheet(
    Sheet sheet,
    List<List<dynamic>> matrix,
    String title,
  ) {
    if (matrix.isEmpty) return;
    final rows = matrix.length;
    final cols = matrix[0].length;

    String displayTitle = title.replaceAll('_', ' ').toUpperCase();
    sheet.appendRow([_cell(displayTitle)]);
    sheet.appendRow([]);

    // Header
    final headerRowData = [''] + List.generate(cols, (j) => 'K${j + 1}');
    sheet.appendRow(headerRowData.map((h) => _cell(h)).toList());

    // Data
    for (int i = 0; i < rows; i++) {
      final row = matrix[i];
      final rowData =
          ['A${i + 1}'] +
          row.map((v) {
            if (v is double) return v.toStringAsFixed(4);
            if (v is int) return v.toString();
            return v.toString();
          }).toList();
      sheet.appendRow(rowData.map((v) => _cell(v)).toList());
    }
  }

  // ==================== INT MATRIX - TANPA STYLE ====================
  static void _addIntMatrixToSheet(
    Sheet sheet,
    List<List<dynamic>> matrix,
    String title,
  ) {
    if (matrix.isEmpty) return;
    final rows = matrix.length;
    final cols = matrix[0].length;

    String displayTitle = title.replaceAll('_', ' ').toUpperCase();
    sheet.appendRow([_cell(displayTitle)]);
    sheet.appendRow([]);

    final headerRowData = [''] + List.generate(cols, (j) => 'K${j + 1}');
    sheet.appendRow(headerRowData.map((h) => _cell(h)).toList());

    for (int i = 0; i < rows; i++) {
      final row = matrix[i];
      final rowData = ['A${i + 1}'] + row.map((v) => v.toString()).toList();
      sheet.appendRow(rowData.map((v) => _cell(v)).toList());
    }
  }

  // ==================== LIST BIASA ====================
  static void _addListToSheet(Sheet sheet, List data) {
    if (data.isEmpty) {
      sheet.appendRow([_cell('Data kosong')]);
      return;
    }
    for (var item in data) {
      if (item is List) {
        final row = <CellValue?>[];
        for (var element in item) {
          row.add(_cell(element));
        }
        sheet.appendRow(row);
      } else {
        sheet.appendRow([_cell(item)]);
      }
    }
  }

  // ==================== MAP ====================
  static void _addMapToSheet(Sheet sheet, Map data, String title) {
    if (data.isEmpty) {
      sheet.appendRow([_cell('Data kosong')]);
      return;
    }
    sheet.appendRow([_cell(title.toUpperCase())]);
    sheet.appendRow([]);

    for (var entry in data.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      if (value is List) {
        final row = <CellValue?>[_cell(key)];
        for (var element in value) {
          if (element is double) {
            row.add(_cell(element.toStringAsFixed(4)));
          } else {
            row.add(_cell(element));
          }
        }
        sheet.appendRow(row);
      } else if (value is Map) {
        sheet.appendRow([_cell(key)]);
        for (var subEntry in value.entries) {
          final subValue = subEntry.value;
          if (subValue is double) {
            sheet.appendRow([
              _cell(''),
              _cell(subEntry.key),
              _cell(subValue.toStringAsFixed(4)),
            ]);
          } else {
            sheet.appendRow([_cell(''), _cell(subEntry.key), _cell(subValue)]);
          }
        }
      } else {
        if (value is double) {
          sheet.appendRow([_cell(key), _cell(value.toStringAsFixed(4))]);
        } else {
          sheet.appendRow([_cell(key), _cell(value)]);
        }
      }
    }
  }

  // ==================== PENYIMPANAN FILE ====================
  static Future<bool> _saveFile(List<int> bytes, String defaultFileName) async {
    final fileName = '$defaultFileName.xlsx';
    final uint8List = Uint8List.fromList(bytes);

    try {
      // Android: simpan langsung ke Downloads tanpa dialog
      if (Platform.isAndroid) {
        final saved = await _saveToDownloadsAndroid(bytes, fileName);
        if (saved) return true;
      }

      // Non-Android atau fallback: gunakan FilePicker
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan File Excel',
        fileName: fileName,
        bytes: uint8List,
        lockParentWindow: false,
      );

      if (outputFile == null) return false;

      final file = File(outputFile);
      if (await file.exists() && await file.length() > 0) {
        debugPrint('File saved successfully: $outputFile');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error saving file: $e');
      if (Platform.isAndroid) {
        return await _saveToDownloadsAndroid(bytes, fileName);
      }
      return false;
    }
  }

  static Future<ExportResult> _saveFileWithStatus(
    List<int> bytes,
    String defaultFileName,
  ) async {
    final fileName = '$defaultFileName.xlsx';
    final uint8List = Uint8List.fromList(bytes);

    try {
      if (Platform.isAndroid) {
        final saved = await _saveToDownloadsAndroid(bytes, fileName);
        if (saved) {
          return ExportResult.success;
        }
      }

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan File Excel',
        fileName: fileName,
        bytes: uint8List,
        lockParentWindow: false,
      );

      if (outputFile == null) return ExportResult.cancelled;

      final file = File(outputFile);
      if (await file.exists() && await file.length() > 0) {
        return ExportResult.success;
      } else {
        return ExportResult.error;
      }
    } catch (e) {
      debugPrint('Error saving file: $e');
      if (Platform.isAndroid) {
        final saved = await _saveToDownloadsAndroid(bytes, fileName);
        return saved ? ExportResult.success : ExportResult.error;
      }
      return ExportResult.error;
    }
  }

  // ==================== SIMPAN LANGSUNG KE DOWNLOADS (ANDROID) ====================
  static Future<bool> _saveToDownloadsAndroid(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      // Beri waktu agar file benar-benar tertulis
      await Future.delayed(const Duration(milliseconds: 300));

      if (await file.exists() && await file.length() > 0) {
        debugPrint('File saved to Downloads: ${file.path}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error saving to Downloads: $e');
      return false;
    }
  }
}
