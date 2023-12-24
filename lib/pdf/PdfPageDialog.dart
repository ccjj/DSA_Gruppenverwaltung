import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

Future<void> PdfPageDialog(BuildContext context, Uint8List pdfData, int page) async {
  ValueNotifier<PdfLoadingState> loadingState = ValueNotifier(PdfLoadingState.loading);
  final PdfController pdfController = PdfController(
    document: PdfDocument.openData(pdfData)..then((value) => loadingState.value =  PdfLoadingState.success),
  );

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        content: ValueListenableBuilder(
          valueListenable: loadingState,
          builder: (context, PdfLoadingState value, child) {
            if (value == PdfLoadingState.success) {
              Future.delayed(const Duration(milliseconds: 300), () {
                pdfController.jumpToPage(page);
              });
              return SizedBox(
                  height: double.infinity,
                  child: AspectRatio(
                      aspectRatio: 1 / 1.414,
                      child: PdfView(controller: pdfController)));
            } else {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator()),
                ],
              ); // Show loading indicator
            }
          },
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if(page < 1) {
                    page--;
                    pdfController.jumpToPage(page);
                  }
                },
              ),
              TextButton(
                child: Text('Schließen'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  if(page < pdfController.pagesCount!) {
                    page++;
                    pdfController.jumpToPage(page);
                  }
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
