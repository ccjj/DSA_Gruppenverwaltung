import 'package:flutter/material.dart';

import '../Held/Held.dart';
import '../chat/ChatMessage.dart';
import '../chat/MessageAmplifySubscriptionService.dart';
import '../globals.dart';
import '../rules/RollManager.dart';
import '../widgets/AnimatedIconButton.dart';
// Other imports you might need like getIt, RollManager, etc.

class AttributeListWidget extends StatelessWidget {
  final Held held;
  bool isOneLine;

  AttributeListWidget({
    super.key,
    required this.held,
    this.isOneLine = false
  });

  @override
  Widget build(BuildContext context) {
    var attributeNameMap = Held.attributeNameMap(held);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: attributeNameMap.entries.map((entry) {
        return ListTile(
          title: isOneLine ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  flex: 2,
                  child: Text(entry.key)),
              Expanded(
                  flex: 1,
                  child: Text(entry.value.toString()))
            ],
          ) : Text(entry.key),
          subtitle: isOneLine ? null : Text('${entry.value}'),
          trailing: AnimatedIconButton(
            icon: Icons.casino_outlined,
            onTap: () {
              String msg = getIt<RollManager>().rollSingleTest(
                  held.name, entry.key, entry.value, 0);
              if (held.owner == cu.uuid) {
                getIt<MessageAmplifySubscriptionService>()
                    .createMessage(msg, held.gruppeId, cu.uuid);
              } else {
                messageController.add(ChatMessage(
                    messageContent: msg,
                    groupId: held.gruppeId,
                    timestamp: DateTime.now(),
                    ownerId: cu.uuid,
                    isPrivate: true));
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
