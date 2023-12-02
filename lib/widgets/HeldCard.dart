import 'package:flutter/material.dart';

import '../Held/Held.dart';
import '../HeldDetailsScreen.dart';
import 'StatBar.dart';

Card HeldCard(Held held, BuildContext context, Function? callback) {
  const insets = EdgeInsets.fromLTRB(16, 8, 16, 8);
  return Card(
    margin: const EdgeInsets.all(8.0),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeldDetailsScreen(held: held),
          ),
        );
      },
      child: Column(
        children: [
          ListTile(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  callback?.call();
                },
              ),
              title: Text(held.name),
              subtitle: Text(held.ausbildung),
              onTap: null),
          Padding(
            padding: insets,
            child: ValueListenableBuilder(
                builder: (context, value, child)  {
                return StatBar(
                  label: "LP",
                  value: held.lp.value,
                  maxValue: held.maxLp.value,
                  color: Colors.red,
                );
              }, valueListenable: held.lp,
            ),
          ),
          if (held.maxAsp != 0)
            Padding(
              padding: insets,
              child: ValueListenableBuilder(
                  builder: (context, value, child)  {
                  return StatBar(
                    label: "ASP",
                    value: held.asp.value,
                    maxValue: held.maxAsp.value,
                    color: Colors.lightBlueAccent,
                  );
                }, valueListenable: held.asp,
              ),
            ),
          Padding(
            padding: insets,
            child: ValueListenableBuilder(
              builder: (context, value, child)  {
                return StatBar(
                    label: "AU",
                    value: held.au.value,
                    maxValue: held.maxAu.value,
                    color: Colors.amber);
              }, valueListenable: held.au,
            ),
          ),
          SizedBox(
            height: 4,
          )
        ],
      ),
    ),
  );
}
