import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PdfDownloadHelper {
  static Future<void> saveAndOpen(List<int> bytes, String filename) async {
    try {
      // Works on ALL platforms — no Platform.isX needed
      final dir = await getApplicationDocumentsDirectory();

      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception('Could not open file: ${result.message}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
