

import 'package:flutter/material.dart';

import '../Held/Held.dart';
import '../chat/ChatMessage.dart';
import '../chat/MessageAmplifySubscriptionService.dart';
import '../globals.dart';
import '../rules/RollManager.dart';
import '../widgets/experimental/SkillList.dart';

class ExpansionTileWithTitle extends StatelessWidget {
  ExpansionTileWithTitle({super.key, required this.child, required this.title, this.hasTitle = false});

  var isTileExpanded = ValueNotifier(false);
  final String title;
  final Widget child;
  final bool hasTitle;


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isTileExpanded,
      builder: (context, value, vchild) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: Text(title, style: hasTitle ? Theme.of(context).textTheme.titleLarge : const TextStyle()),
                children: const [],
                onExpansionChanged: (bool expanded) {
                  isTileExpanded.value = !isTileExpanded.value;
                },
              ),
            ),
            if (isTileExpanded.value)
              Expanded(
                child: child,
              ),
          ],
        );
      }
    );
  }
}