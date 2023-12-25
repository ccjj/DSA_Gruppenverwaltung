import 'dart:collection';
import 'dart:html';
import 'dart:typed_data';

import 'package:dsagruppen/pdf/PdfPageDialog.dart';
import 'package:dsagruppen/rules/RollCalculator.dart';
import 'package:dsagruppen/rules/RollManager.dart';
import 'package:dsagruppen/rules/RuleProvider.dart';
import 'package:dsagruppen/skills/ISkill.dart';
import 'package:dsagruppen/skills/Talent.dart';
import 'package:dsagruppen/skills/TalentRepository%20.dart';
import 'package:dsagruppen/widgets/AnimatedIconButton.dart';
import 'package:dsagruppen/widgets/AsyncText.dart';
import 'package:dsagruppen/widgets/HeldCard.dart';
import 'package:dsagruppen/widgets/MainScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';

import 'Gruppe/Gruppe.dart';
import 'Held/Held.dart';
import 'MeisterPage/RedCrossOverlay.dart';
import 'chat/ChatBottomBar.dart';
import 'chat/ChatMessage.dart';
import 'globals.dart';
import 'io/PdfFileRepository.dart';

class MeisterPage extends StatefulWidget {
  MeisterPage({required this.gruppe});
  Gruppe gruppe;

  @override
  State<MeisterPage> createState() => _MeisterPageState();
}

class _MeisterPageState extends State<MeisterPage> {
  List<Held> matchedHelden = [];

  SplayTreeSet<Talent> talente = getIt<TalentRepository>().Talente;

  List<String> filteredTalente = [];

  ValueNotifier<String> selectedTalent = ValueNotifier("");

  ValueNotifier<int> modificator = ValueNotifier(0);

  ValueNotifier<String> searchString = ValueNotifier("");

  TextEditingController tcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: const Text("Meisterseite"),
      bnb: ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET) ? ChatBottomBar(
        gruppeId: widget.gruppe.uuid,
        stream: messageController.stream,
      ) : null,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: ()  async {
              //TODO refactor, dupe

              String book = "WdS";
              int page = 198;

              Uint8List? uploadedFile = await getIt<PdfRepository>().loadPdfFile(book);

              if(uploadedFile == null) {
                EasyLoading.showError("Buch nicht gefunden: " + book);
                return;
              }
              PdfPageDialog( uploadedFile, page + 1);

            }, child: Text("Patzertabelle")),
            TypeAheadField(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.3),
              debounceDuration: const Duration(milliseconds: 200),
              controller: tcontroller,
              hideOnEmpty: true,
              suggestionsCallback: (search) {
                return talente
                    .where((element) => element.name
                        .toLowerCase()
                        .contains(searchString.value.toLowerCase()))
                    .map((element) => element.name)
                    .toList();
              },
              builder: (context, controller, focusNode) {
                return TextField(
                    onChanged: (value) {
                      searchString.value = value;
                      print(value);
                      //controller.text = value;
                    },
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: false,
                    decoration: InputDecoration(
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () async {
                                focusNode.unfocus();
                                //TODO refactor, dupe
                                ISkill? skill = RuleProvider.getSkillByName(
                                    selectedTalent.value);
                                print(selectedTalent.value);
                                if (skill == null) {
                                  return;
                                }
                                if (skill.seite == null) {
                                  EasyLoading.showError(
                                      "Skill-Seite nicht hinterlegt: ${skill.name}");
                                  return;
                                }
                                var splitted = splitString(skill!.seite!);
                                if (splitted.length != 2) {
                                  print("unexpected split result");
                                  return;
                                }
                                var book = splitted.elementAt(0);
                                int page = int.parse(splitted.elementAt(1));

                                Uint8List? uploadedFile =
                                    await getIt<PdfRepository>()
                                        .loadPdfFile(book);

                                if (uploadedFile == null) {
                                  EasyLoading.showError(
                                      "Buch nicht gefunden: " + book);
                                  return;
                                }
                                PdfPageDialog( uploadedFile, page + 1);
                              },
                              icon: const Icon(Icons.info_outline_rounded)),
                          IconButton(
                              onPressed: () {
                                searchString.value = "";
                                tcontroller.clear();
                                selectedTalent.value = "";
                              },
                              icon: Icon(Icons.clear)),
                        ],
                      ),
                      border: OutlineInputBorder(),
                      labelText: 'Talent',
                    ));
              },
              itemBuilder: (context, talent) {
                return ListTile(
                  title: Text(talent),
                );
              },
              onSelected: (talent) {
                selectedTalent.value = talent;
                tcontroller.text = talent;
                setState(() {});
              },
            ),
            if (selectedTalent.value.trim().isNotEmpty) ...[
              Center(child: Text("Für alle rollen")),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                          modificator.value = int.tryParse(newValue) ?? 0;
                        },
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Center(
                      child: IconButton(
                          onPressed: () {
                            if (selectedTalent.value.trim().isEmpty) {
                              return;
                            }
                            widget.gruppe.helden.forEach((held) {
                              if (!held.talents.keys
                                  .contains(selectedTalent.value)) {
                                return;
                              }
                              //TODO refactor
                              String msg = getIt<RollManager>().rollTalent(held,
                                  selectedTalent.value, modificator.value);
                              messageController.add(ChatMessage(
                                  messageContent: msg,
                                  groupId: held.gruppeId,
                                  timestamp: DateTime.now(),
                                  ownerId: cu.uuid,
                                  isPrivate: true));
                            });
                          },
                          icon: Icon(Icons.casino_outlined))),
                ],
              )
            ],
            Wrap(
                children: widget.gruppe.helden.map((held) {
              return SizedBox(
                  width: MediaQuery.sizeOf(context).width / 2,
                  child: ValueListenableBuilder(
                      valueListenable: selectedTalent,
                      builder: (context, value, child) {
                        return RedCrossOverlay(
                            showOverlay: !held.talents.keys
                                    .contains(selectedTalent.value) &&
                                selectedTalent.value.trim().isNotEmpty,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: HeldCard(held, context, null)),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ValueListenableBuilder(
                                          valueListenable: modificator,
                                          builder: (context, value, child) {
                                            return AsyncText(
                                                callback: () {
                                                  if (selectedTalent.value
                                                      .trim()
                                                      .isEmpty) {
                                                    return Future.value(null);
                                                  }
                                                  ISkill? skill = RuleProvider
                                                      .getSkillByName(
                                                          selectedTalent.value);
                                                  int mod = RuleProvider
                                                      .getModificator(skill,
                                                          modificator.value);
                                                  return RollCalculator
                                                      .calcChance(
                                                          held, skill, mod);
                                                },
                                                showSpinner: false);
                                          }),
                                      if (selectedTalent.value
                                          .trim()
                                          .isNotEmpty)
                                        AnimatedIconButton(
                                          icon: Icons.casino_outlined,
                                          onTap: () {
                                            if (selectedTalent.value
                                                .trim()
                                                .isEmpty) {
                                              return;
                                            }

                                            String msg = getIt<RollManager>()
                                                .rollTalent(
                                                    held,
                                                    selectedTalent.value,
                                                    modificator.value);
                                            //TODO refactor
                                            messageController.add(ChatMessage(
                                                messageContent: msg,
                                                groupId: held.gruppeId,
                                                timestamp: DateTime.now(),
                                                ownerId: cu.uuid,
                                                isPrivate: true));
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ));
                      }));
            }).toList()),
          ],
        ),
      ),
    );
  }
}

//TODO code dupe
List<String> splitString(String input) {
  RegExp exp = RegExp(r'(\d+|\D+)');
  return exp.allMatches(input).map((m) => m.group(0)!).toList();
}
