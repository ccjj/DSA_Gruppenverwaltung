
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../Gruppe/Gruppe.dart';
import '../Note/NoteAmplifyService.dart';
import '../globals.dart';
import '../model/Note.dart';
import 'QuillText.dart';

class NotesExpansionTile extends StatelessWidget {
  const NotesExpansionTile({
    super.key,
    required QuillController controller, required this.gruppe, required this.saveCallback,
  }) : _controller = controller;
  final QuillController _controller;
  final Gruppe gruppe;
  final Function(String) saveCallback;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(title: Text("Notizen"),
      onExpansionChanged: (isExpanded) async {
        if(!isExpanded)
          return;
        //final json = jsonDecode(previouslyStoredJsonString);
        //
        // _controller.document = Document.fromJson(json);
        Note? note = await getIt<NoteAmplifyService>().getNoteForGroup(gruppe.uuid);
        if(note == null){
          print("NOTE IS NULL");
          return;
        }
        List<dynamic> quillJson = jsonDecode(note.content);
        _controller.document = Document.fromJson(quillJson);
      },
      children: [
        RtfTextEditor(controller: _controller, saveCallback: saveCallback,),
      ],
    );
  }
}
