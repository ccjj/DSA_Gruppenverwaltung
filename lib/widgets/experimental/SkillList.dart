import 'dart:collection';
import 'dart:typed_data';

import 'package:dsagruppen/io/PdfFileRepository.dart';
import 'package:dsagruppen/skills/Zauber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pdfx/pdfx.dart';

import '../../Held/Held.dart';
import '../../globals.dart';
import '../../rules/RuleProvider.dart';
import '../../skills/ISkill.dart';
import '../AnimatedIconButton.dart';
import 'SkillChanceText.dart';

class SkillList extends StatefulWidget {
  final Held held;
  final Function(String, int) rollCallback;
  final bool isExpanded;

  final Map<String, int> skillMap;

  const SkillList({super.key,
    required this.held,
    required this.rollCallback,
    required this.skillMap,
    this.isExpanded = true,
  });

  @override
  SkillListState createState() => SkillListState();
}

class SkillListState extends State<SkillList> {
  String searchString = "";

  @override
  Widget build(BuildContext context) {
    Map<String, int> filteredItems;
    if (searchString.trim().isNotEmpty) {
      filteredItems = Map.fromEntries(widget.skillMap.entries.where((entry) =>
          entry.key.toLowerCase().contains(searchString.toLowerCase())));
    } else {
      filteredItems = widget.skillMap;
    }
    SplayTreeMap<String, int> filteredSplayMap = SplayTreeMap.from(filteredItems);

    int totalChildCount = 1 + filteredItems.length * 2;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchString = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Suche',
                  suffixIcon: Icon(Icons.search),
                    fillColor: Colors.grey.withOpacity(0.1),
                    filled: true
                ),
              ),
            );
          }

          if (index.isOdd) {
            return const Divider(height: 1, thickness: 1);
          }

          final itemIndex = (index - 1) ~/ 2;
          final skillName = filteredSplayMap.keys.elementAt(itemIndex);
          final taw = filteredSplayMap.values.elementAt(itemIndex);
          ValueNotifier<int> modificator = ValueNotifier<int>(0);

          return SkillRow(itemIndex: itemIndex, skillName: skillName, taw: taw, modificator: modificator, widget: widget);
        },
        childCount: totalChildCount
      )
    );
  }
}

class SkillRow extends StatefulWidget {
  const SkillRow({
    super.key,
    required this.itemIndex,
    required this.skillName,
    required this.taw,
    required this.modificator,
    required this.widget,
  });

  final int itemIndex;
  final String skillName;
  final int taw;
  final ValueNotifier<int> modificator;
  final SkillList widget;

  @override
  State<SkillRow> createState() => _SkillRowState();
}

class _SkillRowState extends State<SkillRow> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    ISkill? skill = RuleProvider.getSkillByName(widget.skillName);
    super.build(context);
    return DecoratedBox(
      key: ValueKey<int>(widget.itemIndex),
      decoration: BoxDecoration(
        color: widget.itemIndex.isEven
            ? Theme.of(context).highlightColor.withOpacity(0.15)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: Text(widget.skillName, style: const TextStyle(overflow: TextOverflow.ellipsis),)),
                  if(skill != null && skill.seite != null)Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: () async {
                      if(skill.seite == null){
                        EasyLoading.showError("Skill-Seite nicht hinterlegt: ${widget.skillName}");
                        return;
                      }
                      var splitted = splitString(skill!.seite!);
                      if(splitted.length != 2){
                        print("unexpected split result");
                        return;
                      }
                      var book = splitted.elementAt(0);
                      int page = int.parse(splitted.elementAt(1));

                      Uint8List? uploadedFile = await getIt<PdfRepository>().loadPdfFile(book);

                      if(uploadedFile == null) {
                        EasyLoading.showError("Buch nicht gefunden: " + book);
                        return;
                      }
                      showPdfPageDialog(context, uploadedFile, page + 1);
                    }, icon: Icon(Icons.info_outline_rounded)),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(widget.taw.toString()),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const VerticalDivider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 40,
                      height: 32,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (newValue) {
                          widget.modificator.value = int.tryParse(newValue) ?? 0;
                        },
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedIconButton(
                          icon: Icons.casino_outlined,
                          onTap: () =>
                              widget.widget.rollCallback(widget.skillName, widget.taw),
                        ),
                        SkillChanceText(
                          modificator: widget.modificator,
                          skillName: widget.skillName,
                          held: widget.widget.held,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> showPdfPageDialog(BuildContext context, Uint8List pdfData, int page) async {
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

  List<String> splitString(String input) {
    RegExp exp = RegExp(r'(\d+|\D+)');
    return exp.allMatches(input).map((m) => m.group(0)!).toList();
  }

}
