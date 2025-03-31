import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<File> downloadFile(String url, String filename) async {
  // Get temporary directory
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/$filename';

  final file = File(filePath);
  // If the file already exists, return it directly (cache hit)
  if (await file.exists()) {
    return file;
  }

  // Otherwise, download the file from the network
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    await file.writeAsBytes(response.bodyBytes);
    return file;
  } else {
    throw Exception('Failed to download file');
  }
}
