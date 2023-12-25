import 'package:flutter/material.dart';

import '../Held/Held.dart';

class BasiswerteTile extends StatelessWidget {
  final Held held; // Replace with your actual model type.

  const BasiswerteTile({super.key, required this.held});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      iconColor: Colors.red,
      collapsedIconColor: Colors.red,
      title: const Text('Basiswerte'),
      children: <Widget>[
        ListTile(
          title: const Text('Magieresistenz (MR)'),
          subtitle: Text('${held.mr}'),
        ),
        ListTile(
          title: const Text('Initiative (INI)'),
          subtitle: Text('${held.ini} / ${held.baseIni}'),
        ),
        ListTile(
          title: const Text('Basisinitiative'),
          subtitle: Text('${held.baseIni}'),
        ),
        ListTile(
          title: const Text('Angriffswert (AT)'),
          subtitle: Text('${held.at}'),
        ),
        ListTile(
          title: const Text('Parade (PA)'),
          subtitle: Text('${held.pa}'),
        ),
        ListTile(
          title: const Text('Fernkampfwert (FK)'),
          subtitle: Text('${held.fk}'),
        ),
        ListTile(
          title: const Text('Wundschwelle (WS)'),
          subtitle: Text('${held.ws}'),
        ),
      ],
    );
  }
}
