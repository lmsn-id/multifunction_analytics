import 'dart:io';
import 'package:flutter/foundation.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      return true;
    }

    if (Platform.isIOS) {
      return true;
    }

    return true;
  }

  static Future<bool> isPermissionGranted() async {
    return true;
  }
}
