import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/extensions/IterableExtensions.dart';
import 'package:dsagruppen/widgets/AsyncText.dart';
import 'package:dsagruppen/widgets/PlusMinusButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';

import 'Held/Held.dart';
import 'Held/UpdateHeldInput.dart';
import 'MainScaffold.dart';
import 'User/UserAmplifyService.dart';
import 'globals.dart';

class HeldDetailsScreen extends StatefulWidget {
  final Held held;

  const HeldDetailsScreen({super.key, required this.held});

  @override
  State<HeldDetailsScreen> createState() => _HeldDetailsScreenState();
}

class _HeldDetailsScreenState extends State<HeldDetailsScreen> {
  final flipController = FlipCardController();

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "Heldendetails",
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => flipController.flipcard(),
                    child: Card(
                      child: FlipCard(
                        animationDuration: const Duration(milliseconds: 300),
                        controller: flipController,
                        frontWidget: Column(
                          children: [
                            ListTile(
                              contentPadding:EdgeInsets.only(left: 16),
                              leading: Icon(Icons.badge_outlined), // Icon für 'Name'
                              title: Text(widget.held.name),
                              trailing: IconButton(
                                  icon: Icon(Icons.info_outline_rounded),
                                  onPressed: () =>
                                  //_showHeldInfoDialog(context, widget.held),
                                  flipController.flipcard()
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.school), // Icon für 'Ausbildung'
                              title: Text('${widget.held.ausbildung}'),
                            ),
                          ],
                        ),
                        backWidget: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.accessibility_new), // Icon für 'Rasse'
                            title: Text(widget.held.rasse),
                            contentPadding:EdgeInsets.only(left: 16),
                            trailing: IconButton(
                              icon: Icon(Icons.info_outline_rounded),
                              onPressed: () =>
                              //_showHeldInfoDialog(context, widget.held),
                              flipController.flipcard(),
                          ),
                          ),
                          ListTile(
                            leading: Icon(Icons.public), // Icon für 'Kultur'
                            title: Text(widget.held.kultur),
                          ),
                          ListTile(
                            leading: Icon(Icons.star_border), // Icon für 'Abenteuerpunkte (AP)'
                            title: Text(' ${widget.held.ap} AP'),
                          ),
                          ListTile(
                            leading: Icon(Icons.account_circle), // Icon für 'Benutzer'
                            title: AsyncText(prefixText: "Account " ,callback: () async {
                              var foundUser = await getIt<UserAmplifyService>()
                                  .getUser(widget.held.owner);
                              if(foundUser == null){
                                return "?";
                              }
                              return foundUser!.name;
                            },),
                          ),
                        ],
                      ),
                        rotateSide: RotateSide.right,
                        axis: FlipAxis.vertical,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      children: [
                        PlusMinusButton(
                          title: 'Lebenspunkte (LP)',
                          leading: Icon(Icons.favorite, color: Colors.red),
                          value: widget.held.lp.value,
                          maxValue: widget.held.maxLp.value,
                          onValueChanged: (newVal) {
                            getIt<HeldService>().updateHeldFromInput(widget.held, UpdateHeldInput(
                                id: widget.held.uuid,
                                lp: newVal
                            ));
                            setState(() {
                              //TODO repo etc
                              widget.held.lp.value = newVal;
                            });
                          },
                        ),
                        PlusMinusButton(
                          title: 'Astralpunkte (ASP)',
                          leading: Icon(Icons.flash_on_outlined, color: Colors.lightBlueAccent),
                          value: widget.held.asp.value,
                          maxValue: widget.held.maxAsp.value,
                          onValueChanged: (newVal) {
                            getIt<HeldService>().updateHeldFromInput(widget.held, UpdateHeldInput(
                              id: widget.held.uuid,
                              asp: newVal
                            ));
                            setState(() {
                              widget.held.asp.value = newVal;
                            });
                          },
                        ),
                        PlusMinusButton(
                          title: 'Ausdauer (AU)',
                          leading: Icon(Icons.directions_run_outlined, color: Colors.amber),
                          value: widget.held.au.value,
                          maxValue: widget.held.maxAu.value,
                          onValueChanged: (newVal) {
                            getIt<HeldService>().updateHeldFromInput(widget.held, UpdateHeldInput(
                                id: widget.held.uuid,
                                au: newVal
                            ));
                            setState(() {
                              widget.held.au.value = newVal;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              title: Text('Eigenschaften'),
              children: [
                ListTile(
                  title: Text('Mut (MU)'),
                  subtitle: Text('${widget.held.mu}'),
                ),
                ListTile(
                  title: Text('Klugheit (KL)'),
                  subtitle: Text('${widget.held.kl}'),
                ),
                ListTile(
                  title: Text('Intuition (IN)'),
                  subtitle: Text('${widget.held.intu}'),
                ),
                ListTile(
                  title: Text('Charisma (CH)'),
                  subtitle: Text('${widget.held.ch}'),
                ),
                ListTile(
                  title: Text('Fingerfertigkeit (FF)'),
                  subtitle: Text('${widget.held.ff}'),
                ),
                ListTile(
                  title: Text('Gewandtheit (GE)'),
                  subtitle: Text('${widget.held.ge}'),
                ),
                ListTile(
                  title: Text('Konstitution (KO)'),
                  subtitle: Text('${widget.held.ko}'),
                ),
                ListTile(
                  title: Text('Körperkraft (KK)'),
                  subtitle: Text('${widget.held.kk}'),
                ),
                ListTile(
                  title: Text('Sozialstatus (SO)'),
                  subtitle: Text('${widget.held.so}'),
                ),
                ListTile(
                  title: Text('Geschwindigkeit (GS)'),
                  subtitle: Text('${widget.held.gs}'),
                ),
              ],
            ),
            ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              title: Text('Basiswerte'),
              children: <Widget>[
                ListTile(
                  title: Text('Magieresistenz (MR)'),
                  subtitle: Text('${widget.held.mr}'),
                ),
                ListTile(
                  title: Text('Initiative (INI)'),
                  subtitle: Text('${widget.held.ini} / ${widget.held.baseIni}'),
                ),
                ListTile(
                  title: Text('Basisinitiative'),
                  subtitle: Text('${widget.held.baseIni}'),
                ),
                ListTile(
                  title: Text('Angriffswert (AT)'),
                  subtitle: Text('${widget.held.at}'),
                ),
                ListTile(
                  title: Text('Parade (PA)'),
                  subtitle: Text('${widget.held.pa}'),
                ),
                ListTile(
                  title: Text('Fernkampfwert (FK)'),//TODO
                  subtitle: Text('${widget.held.fk}'),
                ),
                ListTile(
                  title: Text('Wundschwelle (WS)'),
                  subtitle: Text('${widget.held.ws}'),
                ),
              ],
            ),
        ExpansionTile(
            iconColor: Colors.red,
            collapsedIconColor: Colors.red,
          title: Text('Vor-/Nachteile'),
          children: [
            SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowHeight: 0,
                columns: const [
                  DataColumn(label: Text('Vorteil')),
                ],
                rows: widget.held.vorteile.indexedMap((index, item) => DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      if (!index.isEven) {
                        return Theme.of(context).highlightColor.withOpacity(0.15);
                      }
                      return null; // Use default color for even rows
                    },
                  ),
                  cells: [
                    DataCell(Text(item)),
                  ],
                )).toList(),
              ),
            )
            ]
        ),
            ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: Text('Sonderfertigkeiten'),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowHeight: 0,
                      columns: const [
                        DataColumn(label: Text('Sonderfertigkeit')),
                      ],
                      rows: widget.held.sf.indexedMap((index, item) => DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (!index.isEven) {
                              return Theme.of(context).highlightColor.withOpacity(0.15);
                            }
                            return null; // Use default color for even rows
                          },
                        ),
                        cells: [
                          DataCell(Text(item)),
                        ],
                      )).toList(),
                    ),
                  )
                ]
            ),
            ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              title: Text('Talente'),
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Talent')),
                      DataColumn(label: Text('Stufe')),
                    ],
                    rows: widget.held.talents.entries
                        .toList().asMap().entries
                        .map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (!index.isOdd) {
                              return Theme.of(context).highlightColor.withOpacity(0.15);
                            }
                            return null; // Use default color for even rows
                          },
                        ),
                        cells: [
                          DataCell(Text(item.key)), // The original key from the map
                          DataCell(Text('${item.value}')), // The original value from the map
                        ],
                      );
                    })
                        .toList(),
                  ),
                )
              ],
            ),
            Visibility(
              visible: widget.held.zauber.isNotEmpty,
              child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: Text('Zauber'),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Zauber')),
                        DataColumn(label: Text('Stufe')),
                      ],
                      rows: widget.held.zauber.entries.toList().asMap().entries
                          .map((entry) {
                        int index = entry.key;
                        var item = entry.value;
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (!index.isOdd) {
                                return Theme.of(context).highlightColor.withOpacity(0.15);
                              }
                              return null; // Use default color for even rows
                            },
                          ),
                        cells: [
                          DataCell(Text(item.key)),
                          DataCell(Text('${item.value}')),
                        ],
                      );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
            ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              title: Text('Items'),
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Item')),
                      DataColumn(label: Text('Anzahl')),
                    ],
                    rows: widget.held.items.entries.toList().asMap().entries
                        .map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (!index.isOdd) {
                              return Theme.of(context).highlightColor.withOpacity(0.15);
                            }
                            return null; // Use default color for even rows
                          },
                        ),
                      cells: [
                        DataCell(Text(item.key)),
                        DataCell(Text('${item.value}')),
                      ],
                    );}).toList(),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAttributeDialog(
      BuildContext context,
      String title,
      String currentValue,
      void Function(String) onSave,
      ) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Neuer Wert'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Speichern'),
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showHeldInfoDialog(BuildContext context, Held held){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Details ${held.name}"),
          content: Column(
            children: [
              ListTile(
                leading: Icon(Icons.accessibility_new), // Icon für 'Rasse'
                title: Text(held.rasse),
              ),
              ListTile(
                leading: Icon(Icons.public), // Icon für 'Kultur'
                title: Text(held.kultur),
              ),
              ListTile(
                leading: Icon(Icons.star_border), // Icon für 'Abenteuerpunkte (AP)'
                title: Text(' ${held.ap} AP'),
              ),
              ListTile(
                leading: Icon(Icons.account_circle), // Icon für 'Benutzer'
                title: AsyncText(prefixText: "Account " ,callback: () async {
                  var foundUser = await getIt<UserAmplifyService>()
                      .getUser(held.owner);
                  if(foundUser == null){
                    return "?";
                  }
                  return foundUser!.name;
                },),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String talentsToString(Map<String, int> talents) {
    return talents.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  String itemsToString(Map<String, int> items) {
    return items.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}
