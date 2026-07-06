import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class WebFilePicker {
  static Future<Uint8List?> pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      if (file.bytes != null) {
        return file.bytes;
      }

      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }
}
