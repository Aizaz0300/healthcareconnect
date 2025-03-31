import 'dart:io';
//import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class DocumentHandler {
  static const List<String> allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
  static const int maxFileSizeInMB = 5;

  static Future<File?> pickDocument() async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: allowedExtensions,
      // );
      const result=null;
      if (result != null) {
        File file = File(result.files.single.path!);
        if (await _validateFileSize(file)) {
          return file;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> _validateFileSize(File file) async {
    final bytes = await file.length();
    final sizeInMB = bytes / (1024 * 1024);
    return sizeInMB <= maxFileSizeInMB;
  }

  static String getFileExtension(File file) {
    return path.extension(file.path).toLowerCase().replaceAll('.', '');
  }

  static String getFileName(File file) {
    return path.basename(file.path);
  }
}
