import 'package:flutter/material.dart';

class PopupMenuButtonItems extends StatelessWidget {

  const PopupMenuButtonItems({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      child: const Icon(
        Icons.more_vert,
      ),
      onSelected: (int val) async {
        switch (val) {
          case 1:
            {
              //TODO add note
              break;
            }
          case 2:
            {
              //TODO delete item
              break;
            }
          default:
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.delete),
              Text("Löschen"),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.note_alt_outlined),
              Text("Bemerkungen"),
            ],
          ),
        ),
      ],
    );
  }
}
