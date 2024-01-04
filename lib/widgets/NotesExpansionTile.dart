
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';

import '../Gruppe/Gruppe.dart';
import '../Note/NoteAmplifyService.dart';
import '../globals.dart';
import '../model/Note.dart';
import 'QuillText.dart';

class NotesExpansionTile extends StatelessWidget {
  const NotesExpansionTile({
    super.key,
    required QuillController controller, required this.saveCallback, required this.getNoteCallback
  }) : _controller = controller;
  final QuillController _controller;
  final Function(String) saveCallback;
  final Function getNoteCallback;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(title: Text("Notizen", style: (ResponsiveBreakpoints.of(context).largerThan(TABLET)) ? Theme.of(context).textTheme.titleLarge : TextStyle()),
            iconColor: Colors.red,
            collapsedIconColor: Colors.red,
            onExpansionChanged: (isExpanded) async {
              if(!isExpanded)
                return;
              getNoteCallback.call();
            },
            children: [
              SizedBox(
                  height: constrains.maxHeight - 190,
                  child: RtfTextEditor(controller: _controller, saveCallback: saveCallback,)),
            ],
          ),
        );
      }
    );
  }
}
