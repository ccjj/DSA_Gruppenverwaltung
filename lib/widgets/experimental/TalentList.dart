import 'dart:collection';

import 'package:flutter/material.dart';

// Import your relevant packages and models
import '../../Held/Held.dart';
import '../../rules/RuleProvider.dart';
import '../../rules/RollCalculator.dart';
import '../../skills/ISkill.dart';
import '../AnimatedIconButton.dart';
import '../AsyncText.dart';

class TalentList extends StatefulWidget {
  final Held held;
  final Function(String, int) rollCallback;
  final bool isExpanded;

  const TalentList({super.key,
    required this.held,
    required this.rollCallback,
    this.isExpanded = true,
  });

  @override
  TalentListState createState() => TalentListState();
}

class TalentListState extends State<TalentList> {
  String searchString = "";

  @override
  Widget build(BuildContext context) {
    //Map<String, int> items = widget.held.talents;
    Map<String, int> filteredItems;
    if (searchString.trim().isNotEmpty) {
      filteredItems = Map.fromEntries(widget.held.talents.entries.where((entry) =>
          entry.key.toLowerCase().contains(searchString.toLowerCase())));
    } else {
      filteredItems = widget.held.talents;
    }
    SplayTreeMap<String, int> filteredSplayMap = SplayTreeMap.from(filteredItems);

    int totalChildCount = 1 + filteredItems.length * 2;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        //addAutomaticKeepAlives: false,
        //addRepaintBoundaries: false,
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
                decoration: const InputDecoration(
                  labelText: 'Suche',
                  suffixIcon: Icon(Icons.search),
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

          return DecoratedBox(
            key: ValueKey<int>(index),
            decoration: BoxDecoration(
              color: itemIndex.isEven
                  ? Theme.of(context).highlightColor.withOpacity(0.15)
                  : null,
            ),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    flex: 2, // Adjust flex to manage width
                    child: Text(skillName),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(taw.toString()),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const VerticalDivider(),
                        SizedBox(
                          width: 40,
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
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedIconButton(
                                icon: Icons.casino_outlined,
                                onTap: () =>
                                    widget.rollCallback(skillName, taw),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: modificator,
                                builder: (context, value, child) {
                                  return AsyncText(
                                    callback: () async {
                                      ISkill? skill =
                                      RuleProvider.getSkillByName(
                                          skillName);
                                      int mod = RuleProvider.getModificator(
                                          widget.held, skill, value);
                                      return RollCalculator.calcChance(
                                          widget.held, skill, mod);
                                    },
                                    showSpinner: false,
                                  );
                                },
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
        },
        childCount: totalChildCount, // Account for dividers
      ),
    );
  }
}
