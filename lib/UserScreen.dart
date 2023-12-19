import 'dart:async';
import 'dart:typed_data';

import 'package:dsagruppen/widgets/HeldCard.dart';
import 'package:dsagruppen/widgets/RedBookWidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:pdfx/pdfx.dart';

import 'Held/HeldRepository.dart';
import 'HeldGroupCoordinator.dart';
import 'UserPreferences.dart';
import 'globals.dart';
import 'io/PdfFileRepository.dart';
import 'widgets/MainScaffold.dart';

class UserScreen extends StatefulWidget {
  UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  PdfController? pdfController;
  var pdfRepo = getIt<PdfRepository>();
  late Map<String, String> books;
  String? selectedBook;
  final ValueNotifier<Map<String, String>> bookNotifier = ValueNotifier(<String, String>{});

  @override
  void initState() {
    books = pdfRepo.getBookTitles();
    books.entries.forEach((entry) {
      pdfRepo.loadPdfFile(entry.key).then((value) {
        if(value != null){
          updateMap(entry.key, entry.value);
        }
      });
    });
    super.initState();
  }

  void updateMap(String key, String value) {
    bookNotifier.value = Map<String, String>.from(bookNotifier.value)..[key] = value;
  }

  void removeItem(String key) {
    var newMap = Map<String, String>.from(bookNotifier.value);
    newMap.remove(key);
    bookNotifier.value = newMap;
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: const Text("Benutzerdetails"),
      body: Column(
        children: [
          Text(cu.name),
          Text(cu.email),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Ausdauerbalken anzeigen"),
              Switch(
                activeColor: Colors.amber,
                value: showAusdauer.value,
                onChanged: (bool newValue) {
                  getIt<UserPreferences>().saveShowAusdauer(newValue);
                  showAusdauer.value = newValue;
                  setState(() {
                  });
                },
              ),
            ],
          ),
          DropdownButton(
            value: selectedBook,
            hint: Text("Buch wählen"),
            onChanged: (String? newValue) {
              setState(() {
                selectedBook = newValue;
              });
            },
            items: books.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    if(selectedBook == null){
                      EasyLoading.showError("Kein Buch ausgewählt");
                      return;
                    }
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    Uint8List? uploadedFile;
                    if (result != null) {
                      PlatformFile file = result.files.first;
                        uploadedFile = file.bytes;
                      if(await pdfRepo.savePdfFile(uploadedFile!, selectedBook!) == false){
                        EasyLoading.showError("Datei konnte nicht gespeichert werden");
                        return;
                      }
                      updateMap(selectedBook!, books[selectedBook]!);
                    }
                  },
                  child: const Text('Upload'),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          ValueListenableBuilder<Map<String, String>>(
            valueListenable: bookNotifier,
            builder: (context, map, child) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: map.entries.map((entry) {
                  return RedBookWidget(title: entry.value);
                }).toList(),
              );
            },
          ),
          SizedBox(height: 10),
          //TODO same widget list for user and group
          ListView(
            shrinkWrap: true,
            children: [
              ...getIt<HeldRepository>().getHeldenByUser(cu.uuid).map((h) =>
                HeldCard(h, context, () {
                  getIt<HeldGroupCoordinator>().removeHeldCompletely(h);
                  //setstate
                })
              )
            ],
          )
        ],
      ),
    );
  }

}
