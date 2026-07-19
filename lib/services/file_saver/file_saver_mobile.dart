import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> saveFileBytes(String filename, List<int> bytes, String mimeType) async {
  final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);
}
