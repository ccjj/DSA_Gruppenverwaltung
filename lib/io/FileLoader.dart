import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FileLoader {
  static Future<List<dynamic>> loadJsonList(String filePath) async {
    String content = await rootBundle.loadString(filePath);
    return json.decode(content);
  }
}
