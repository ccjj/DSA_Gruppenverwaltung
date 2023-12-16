import 'package:dsagruppen/widgets/HeldCard.dart';
import 'package:flutter/material.dart';

import 'Held/HeldRepository.dart';
import 'HeldGroupCoordinator.dart';
import 'UserPreferences.dart';
import 'widgets/MainScaffold.dart';
import 'globals.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: Text("Benutzerdetails"),
      body: Column(
        children: [
          Text(cu.name),
          Text(cu.email),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Ausdauerbalken anzeigen"),
              Switch(
                activeColor: Colors.amber,
                value: showAusdauer.value,
                onChanged: (bool newValue) {
                  getIt<UserPreferences>().saveShowAusdauer(newValue);
                  showAusdauer.value = newValue;
                  setState(() {
                  });
                },
              ),
            ],
          ),
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
