import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileUtils {
  static Future<String> get getFilePath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> getFile(String name) async {
    final path = await getFilePath;
    print(path);
    return File('$path/$name');
  }

  static Future<File> saveToFile(String data, String fileName) async {
    final file = await getFile(fileName);

    return file.writeAsString(data);
  }

  static Future<String> readFromFile(String fileName) async {
    try {
      final file = await getFile(fileName);
      String fileContents = await file.readAsString();
      return fileContents;
    }catch(e) {
      return "$e";
    }
  }
}