import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RtfTextEditor extends StatefulWidget {
  QuillController controller;
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
      child: LayoutBuilder(
        builder: (context, constrains) {

          print(constrains.maxHeight);
          print(constrains.minHeight);
          print(constrains.hasBoundedHeight);
          return Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QuillToolbar(
                  configurations: QuillToolbarConfigurations(

                  ), child: Wrap(
                  children: [
                    QuillToolbarHistoryButton(
                      isUndo: true,
                      controller: widget.controller,
                    ),
                    QuillToolbarHistoryButton(
                      isUndo: false,
                      controller: widget.controller,
                    ),
                    QuillToolbarFontSizeButton(
                      controller: widget.controller,
                    ),
                    QuillToolbarToggleStyleButton(
                      options: const QuillToolbarToggleStyleButtonOptions(),
                      controller: widget.controller,
                      attribute: Attribute.bold,
                    ),
                    QuillToolbarToggleStyleButton(
                      options: const QuillToolbarToggleStyleButtonOptions(),
                      controller: widget.controller,
                      attribute: Attribute.italic,
                    ),
                    QuillToolbarToggleStyleButton(
                      controller: widget.controller,
                      attribute: Attribute.underline,
                    ),
                    QuillToolbarColorButton(
                      controller: widget.controller,
                      isBackground: false,
                    ),
                    QuillToolbarClearFormatButton(
                      controller: widget.controller,
                    ),
                    const VerticalDivider(),
                    IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () {
                          var json = jsonEncode(widget.controller.document.toDelta().toJson());
                          widget.saveCallback(json);
                        }
                    ),
                  ],
                )
                ),

                Flexible(
                  fit: FlexFit.loose,
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      scrollable: true,
                      isOnTapOutsideEnabled: true,
                      autoFocus: true,
                      expands: true,
                      scrollPhysics: AlwaysScrollableScrollPhysics(), controller: widget.controller!,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
