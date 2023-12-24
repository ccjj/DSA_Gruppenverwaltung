
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pdfx/pdfx.dart';

import '../Held/Held.dart';
import '../globals.dart';
import '../io/PdfFileRepository.dart';
import '../pdf/PdfPageDialog.dart';
import '../rules/RuleProvider.dart';
import '../widgets/AnimatedIconButton.dart';
import '../widgets/experimental/SkillChanceText.dart';
import 'ISkill.dart';
import '../widgets/experimental/SkillList.dart';

class SkillRow extends StatefulWidget {
  const SkillRow({
    super.key,
    required this.itemIndex,
    required this.skillName,
    required this.taw,
    required this.modificator,
    required this.held,
    required this.rollCallback
  });

  final int itemIndex;
  final String skillName;
  final int taw;
  final Held held;
  final Function rollCallback;
  final ValueNotifier<int> modificator;

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
              flex: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: Tooltip(
                          message: widget.skillName,
                          child: Text(widget.skillName, style: const TextStyle(overflow: TextOverflow.ellipsis),))),
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
                          PdfPageDialog(context, uploadedFile, page + 1);
                        }, icon: const Icon(Icons.info_outline_rounded)),
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
              flex: 4,
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
                              widget.rollCallback(widget.skillName, widget.taw, widget.modificator.value),
                        ),
                        SkillChanceText(
                          modificator: widget.modificator,
                          skillName: widget.skillName,
                          held: widget.held,
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


  List<String> splitString(String input) {
    RegExp exp = RegExp(r'(\d+|\D+)');
    return exp.allMatches(input).map((m) => m.group(0)!).toList();
  }

}
