import 'package:dsagruppen/widgets/HeldCard.dart';
import 'package:flutter/material.dart';

import 'Held/HeldRepository.dart';
import 'HeldGroupCoordinator.dart';
import 'MainScaffold.dart';
import 'globals.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "Benutzerdetails",
      body: Column(
        children: [
          Text(cu.name),
          Text(cu.email),
          //TODO same widget list for user and group
          ListView(
            shrinkWrap: true,
            children: [
              ...getIt<HeldRepository>().getHeldenByUser(cu.uuid).map((h) =>
                HeldCard(h, context, () {
                  getIt<HeldGroupCoordinator>().removeHeldCompletely(h);
                  //setstate
                })
              )
            ],
          )
        ],
      ),
    );
  }
}
