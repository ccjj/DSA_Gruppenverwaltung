import 'package:flutter/material.dart';

import '../globals.dart';

Future<void> showDiceRollExplanationDialog(BuildContext context) async {
  await showDialog(
    context:  navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Anleitung'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Würfeln:\n',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    TextSpan(
                      text: 'Du kannst Würfel durch Eingabe der folgenden Formate werfen:\n\n',
                    ),
                    TextSpan(
                      text: '1. Standard Format:\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '   - XdY oder XwY (Groß- oder Kleinschreibung egal)\n'
                          '   - X = Anzahl der Würfel (optional, Standard = 1)\n'
                          '   - Y = Anzahl der Seiten pro Würfel\n'
                          '   - Beispiel: 3d6 (3 Würfel mit je 6 Seiten)\n\n',
                    ),
                    TextSpan(
                      text: '2. Alternatives Format:\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '   - /roll XdY oder /*roll XwY\n'
                          '   - /roll ist optional\n'
                          '   - Beispiel: /roll 2d20\n\n',
                    ),
                    TextSpan(
                      text: 'Weitere Hinweise:\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '   - Wenn die Anzahl der Würfel nicht angegeben wird, wird standardmäßig 1 Würfel verwendet.\n'
                          '   - Beispiele gültiger Eingaben:\n'
                          '     - d6 (1 Würfel mit 6 Seiten)\n'
                          '     - 4d12 (4 Würfel mit 12 Seiten)\n'
                          '     - /roll 3d10 (3 Würfel mit 10 Seiten)\n',
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Würfeln per Spracherkennung:\n',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    TextSpan(
                      text: 'Du kannst würfeln, indem du per Sprachbutton im Chat deine Stimme aufnimmst. Folgende Formate werden erkannt als Eingabe:\n\n',
                    ),
                    TextSpan(
                      text: '1. Standard Format:\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '   - Würfel auf SKILLNAME\n'
                          '   - Würfel auf SKILLNAME erschwert um X\n'
                          '   - Rolle auf SKILLNAME erleichtert um X\n'
                          '   - Beispiel: Würfel auf Magiekunde erschwert um 3\n\n',
                    ),
                    TextSpan(
                      text: 'Weitere Hinweise:\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '   - Wenn die Eingabe nicht erkannt wird, wird keine Nachricht abgeschickt.\n'
                              '   - Andere erlaubte Satzanfänge: "würfel", "würfle", "roll", "rolle", "wirf"\n'
                              '   - Funktioniert nur in ',
                        ),
                        TextSpan(
                          text: 'Chrome',
                          style: TextStyle(color: Colors.red),
                        ),
                        TextSpan(
                          text: ' oder ',
                        ),
                        TextSpan(
                          text: 'Safari',
                          style: TextStyle(color: Colors.red),
                        ),
                        TextSpan(
                          text: '\n   - Experimentelles Feature',
                        ),
                      ],
                    )

                  ],
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
