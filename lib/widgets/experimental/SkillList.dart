import 'dart:collection';
import 'dart:typed_data';

import 'package:dsagruppen/io/PdfFileRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pdfx/pdfx.dart';

import '../../Held/Held.dart';
import '../../globals.dart';
import '../../rules/RuleProvider.dart';
import '../../skills/ISkill.dart';
import '../../skills/SkillRow.dart';
import '../AnimatedIconButton.dart';
import 'SkillChanceText.dart';

class SkillList extends StatefulWidget {
  final Held held;
  final Function(String, int, int) rollCallback;
  final bool hasSliverParent;

  final Map<String, int> skillMap;

  const SkillList({super.key,
    required this.held,
    required this.rollCallback,
    required this.skillMap,
    required this.hasSliverParent
  });

  @override
  SkillListState createState() => SkillListState();
}

class SkillListState extends State<SkillList> {
  String searchString = "";
  Map<String, int> filteredItems = {};
  SplayTreeMap<String, int> filteredSplayMap = SplayTreeMap<String, int>();
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (searchString.trim().isNotEmpty) {
      filteredItems = Map.fromEntries(widget.skillMap.entries.where((entry) =>
          entry.key.toLowerCase().contains(searchString.toLowerCase())));
    } else {
      filteredItems = widget.skillMap;
    }
    filteredSplayMap = SplayTreeMap.from(filteredItems);

    int totalChildCount = 1 + filteredItems.length * 2;
    if(widget.hasSliverParent){
      return SliverList(
        delegate: SliverChildBuilderDelegate(
       childCount: totalChildCount,
                (context, index) => buildItem(context, index)
            )
      );
    }
    return ListView.builder(
        itemCount: totalChildCount,
        itemBuilder: (context, index) {
          return buildItem(context, index);
        },
      );
  }

  Widget buildItem(BuildContext context, int index) {
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: TextField(
          controller: textController,
          onChanged: (value) {
            setState(() {
              searchString = value;
            });
          },
          decoration: InputDecoration(
              suffix: IconButton(
                icon: Icon(Icons.clear),
                onPressed: (){
                  setState(() {
                    searchString = "";
                    textController.clear();
                  });
                },
              ),
              labelText: 'Suche',
              //suffixIcon: Icon(Icons.search),
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

    return SkillRow(itemIndex: itemIndex, skillName: skillName, taw: taw, modificator: modificator, held: widget.held, rollCallback: widget.rollCallback);
  }
}
