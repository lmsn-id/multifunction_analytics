import 'dart:typed_data';
import 'package:excel/excel.dart';

class ExcelService {
  static Future<List<List<dynamic>>> readExcel(Uint8List bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return [];

      final data = <List<dynamic>>[];

      for (var row in sheet.rows) {
        final rowData = <dynamic>[];
        for (var cell in row) {
          if (cell != null && cell.value != null) {
            rowData.add(cell.value);
          } else {
            rowData.add(null);
          }
        }
        if (rowData.isNotEmpty && rowData.any((e) => e != null)) {
          data.add(rowData);
        }
      }

      return data;
    } catch (e) {
      throw Exception('Gagal membaca file Excel: $e');
    }
  }

  static List<String> getHeaders(List<List<dynamic>> data) {
    if (data.isEmpty) return [];
    return data[0].map((e) => e?.toString() ?? '').toList();
  }

  static List<List<dynamic>> getDataWithoutHeaders(List<List<dynamic>> data) {
    if (data.isEmpty) return [];
    return data.sublist(1);
  }

  static bool isValidData(List<List<dynamic>> data) {
    if (data.isEmpty) return false;
    if (data.length < 2) return false;

    final header = data[0];
    if (header.isEmpty) return false;

    final firstRowLength = header.length;
    for (var row in data) {
      if (row.length != firstRowLength) return false;
    }

    return true;
  }

  static Map<String, dynamic> prepareDataFromFiltered(
    List<List<dynamic>> filteredData,
  ) {
    if (filteredData.isEmpty || filteredData.length < 2) {
      throw Exception('Data tidak valid');
    }

    final headers = filteredData[0];

    final rows = filteredData.sublist(1);

    final alternativeNames = <String>[];
    for (var row in rows) {
      final name = row[0]?.toString().trim() ?? '';
      alternativeNames.add(
        name.isNotEmpty ? name : 'Alternatif ${alternativeNames.length + 1}',
      );
    }

    final criteriaNames = <String>[];
    for (int j = 1; j < headers.length; j++) {
      final name = headers[j]?.toString().trim() ?? '';
      criteriaNames.add(
        name.isNotEmpty ? name : 'Kriteria ${criteriaNames.length + 1}',
      );
    }

    final matrix = <List<double>>[];
    for (var row in rows) {
      final rowData = <double>[];
      for (int j = 1; j < row.length; j++) {
        final value = row[j];
        double parsedValue = 0.0;

        if (value == null) {
          parsedValue = 0.0;
        } else if (value is int) {
          parsedValue = value.toDouble();
        } else if (value is double) {
          parsedValue = value;
        } else if (value is num) {
          parsedValue = value.toDouble();
        } else if (value is String) {
          final cleaned = value.trim().replaceAll(',', '.');
          parsedValue = double.tryParse(cleaned) ?? 0.0;
        } else {
          // Coba konversi dari toString
          final str = value.toString().trim();
          parsedValue = double.tryParse(str) ?? 0.0;
        }

        rowData.add(parsedValue);
      }
      matrix.add(rowData);
    }

    return {
      'alternativeNames': alternativeNames,
      'criteriaNames': criteriaNames,
      'matrix': matrix,
    };
  }

  static Map<String, dynamic> prepareDataForMatrix(
    List<List<dynamic>> data,
    int startRow,
    int endRow,
    int startCol,
    int endCol,
  ) {
    final headers = data[0];
    final rows = data.sublist(1);
    final filteredData = <List<dynamic>>[];

    final headerRow = headers.sublist(startCol, endCol + 1);
    filteredData.add(headerRow);

    for (int i = startRow; i <= endRow && i < rows.length; i++) {
      final row = rows[i].sublist(startCol, endCol + 1);
      filteredData.add(row);
    }

    return prepareDataFromFiltered(filteredData);
  }
}
