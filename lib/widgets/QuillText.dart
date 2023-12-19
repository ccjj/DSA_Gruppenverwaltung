import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RtfTextEditor extends StatefulWidget {
  QuillController? controller;
  Function(String) saveCallback;

  RtfTextEditor({
    super.key,
    QuillController? controller,
    required this.saveCallback
  }) : controller = controller ?? QuillController.basic();

  @override
  State<RtfTextEditor> createState() => _RtfTextEditorState();
}


class _RtfTextEditorState extends State<RtfTextEditor> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: QuillProvider(
          configurations: QuillConfigurations(
            controller: widget.controller!,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('de'),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QuillToolbar(
                configurations: QuillToolbarConfigurations(
                  customButtons: [
                    QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        var json = jsonEncode(widget.controller!.document.toDelta().toJson());
                        widget.saveCallback(json);
                      }
                    ),
                  ],
                  showCodeBlock: false,
                  showInlineCode: false,
                  showIndent: false,
                  showListBullets: false,
                  showListCheck: false,
                  showListNumbers: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showBackgroundColorButton: false,
                  showStrikeThrough: false,
                  showQuote: false,
                  showLink: false,
                  showFontFamily: false,
                  showCenterAlignment: false,
                  showHeaderStyle: false,
                ),
              ),
              Expanded(
                child: QuillEditor.basic(
                  configurations: const QuillEditorConfigurations(
                      readOnly: false,scrollable: true,
                      isOnTapOutsideEnabled: true,
                    autoFocus: true,
                    expands: false,
                    scrollPhysics: AlwaysScrollableScrollPhysics(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
