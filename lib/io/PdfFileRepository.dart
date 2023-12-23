import 'dart:typed_data';

import 'package:hive/hive.dart';

class PdfRepository {
  final Map<String, String> books = {
    'LCD' : 'Liber Cantiones Deluxe',
    'OiC' : 'Ordnung ins Chaos',
    'EG' : 'Elementare Gewalten',
    'SoG' : 'Stätten okkulter Geheimnisse',
    'WdS' : 'Wege des Schwerts',
  };

  Map<String, String> getBookTitles() {
    return books;
  }

  Future<bool> savePdfFile(Uint8List pdfFile, String pdfName) async {
    try {
      var box = await Hive.openBox<Uint8List>(pdfName);
      await box.put(pdfName, pdfFile);
      await box.close();
      return true;
    } catch (_){
      return false;
    }
  }

  Future<Uint8List?> loadPdfFile(String bookName) async {
    if(!books.keys.contains(bookName)){
      print("book $bookName not found");
      return null;
    }
    var box = await Hive.openBox<Uint8List>(bookName);
    Uint8List? file = box.get(bookName);
    await box.close();
    return file;
  }
}
