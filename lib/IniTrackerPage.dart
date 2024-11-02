import 'package:dsagruppen/widgets/MainScaffold.dart';
import 'package:dsagruppen/widgets/PlusMinusButton.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'Gruppe/Gruppe.dart';
import 'Held/FightEntity.dart';
import 'Held/Held.dart';
import 'Held/Person.dart';
import 'chat/BottomBar/ChatBottomBar.dart';
import 'globals.dart';

class IniTrackerPage extends StatefulWidget {
  Gruppe gruppe;

  IniTrackerPage({super.key, required this.gruppe});

  @override
  State<IniTrackerPage> createState() => _IniTrackerPageState();
}

class _IniTrackerPageState extends State<IniTrackerPage> {
  TextEditingController iniController = TextEditingController();
  List<Person> persons = [];
  int runde = 1;
  bool displayAusdauer = false;
  bool lowHpRules = false;

  @override
  void initState() {
    super.initState();
    widget.gruppe.helden
        .forEach((held) => persons.add(Held.fromJson(held.toJson())));
    //persons.addAll(widget.gruppe.helden);
    sortPersons();
  }

  @override
  void dispose() {
    iniController.dispose();
    super.dispose();
  }

  void sortPersons() {
    setState(() {
      persons.sort((a, b) => b.ini.compareTo(a.ini));
    });
  }

  void addPerson(Person person) {
    setState(() {
      persons.add(person);
      sortPersons();
    });
  }

  void editInitiative(Person person, int newIni) {
    setState(() {
      person.ini = newIni;
      sortPersons();
    });
  }

  void nextRound() {
    runde++;
    sortPersons();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
        title: const Text("Ini-Tracker"),
        fab: FloatingActionButton(
          onPressed: _showAddPersonDialog,
          tooltip: 'Neue Entität hinzufügen',
          child: const Icon(Icons.add),
        ),
        bnb: ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET)
            ? ChatBottomBar(
                gruppeId: widget.gruppe.uuid,
                stream: messageController.stream,
              )
            : null,
        body: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("Runde: $runde"),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: nextRound,
                  tooltip: 'Nächste Runde',
                ),
                TextButton(onPressed: _resetRounds, child: const Text("reset")),
                IconButton(onPressed: sortPersons, icon: const Icon(Icons.swap_vert)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Zeige Ausdauer"),
                    Checkbox(
                        value: displayAusdauer,
                        onChanged: (checked) => setState(() {
                              displayAusdauer = checked ?? false;
                            })),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Niedrige LP Regeln"),
                    Checkbox(
                        value: lowHpRules,
                        onChanged: (checked) => setState(() {
                              lowHpRules = checked ?? false;
                            })),
                  ],
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index];
                  return InkWell(
                    onTap: () => _showEditDialog(person),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    person.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        'Initiative: ${person.ini}/${person.baseIni}'),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: PlusMinusButton(
                                      title: 'Lebenspunkte (LP)',
                                      isRow: true,
                                      enabled: true,
                                      leading: const Icon(Icons.favorite,
                                          color: Colors.red),
                                      value: person.lp,
                                      maxValue: person.maxLp.value,
                                      onValueChanged: (newVal) {
                                        if(lowHpRules){
                                          if (person.maxLp.value / 4 > person.lp.value) {
                                            //person.ini -= 3;
                                          } else if (person.maxLp.value / 3 > person.lp.value) {
                                            //person.ini -= 2;
                                          } else if (person.maxLp.value / 2 > person.lp.value) {
                                            //person.ini -= 1;
                                          }
                                        }
                                        person.lp.value = newVal;
                                        //setState(() {});
                                      },
                                    ),
                                  ),
                                  if (displayAusdauer)
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: PlusMinusButton(
                                        title: 'Ausdauer (AU)',
                                        isRow: true,
                                        enabled: true,
                                        leading: const Icon(
                                            Icons.directions_run,
                                            color: Colors.amber),
                                        value: person.au,
                                        maxValue: person.maxAu.value,
                                        onValueChanged: (newVal) {
                                          setState(() {
                                            person.au.value = newVal;
                                          });
                                        },
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  if (person.heldNummer.isEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deletePerson(person),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  void _deletePerson(Person person) {
    persons.removeWhere((p) => p.uuid == person.uuid);
    setState(() {});
  }

  void _showAddPersonDialog() {
    String name = '';
    int ini = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neue Person hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Initiative'),
                keyboardType: TextInputType.number,
                onChanged: (value) => ini = int.tryParse(value) ?? 0,
              ),
              // Hier kannst du weitere Felder für die anderen Eigenschaften hinzufügen
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Hinzufügen'),
              onPressed: () {
                if (name.isNotEmpty) {
                  addPerson(FightEntity(
                    name: name,
                    heldNummer: '',
                    owner: '',
                    gruppeId: '',
                    at: 8,
                    pa: 8,
                    fk: 5,
                    ini: ini,
                    baseIni: ini,
                    mr: 5,
                    gs: 7,
                    ws: 5,
                    initialLp: 20,
                    initialMaxLp: 20,
                    initialAsp: 0,
                    initialMaxAsp: 0,
                    initialAu: 24,
                    initialMaxAu: 24,
                  ));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _resetRounds() {
    runde = 1;
    persons.clear();
    widget.gruppe.helden
        .forEach((held) => persons.add(Held.fromJson(held.toJson())));
    sortPersons();
  }

  void _showEditDialog(Person person) {
    int newIni = person.ini;
    iniController.text = newIni.toString();
    iniController.selection = TextSelection(
        baseOffset: 0, extentOffset: iniController.value.text.length);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Initiative bearbeiten'),
          content: TextFormField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Neue Initiative'),
            controller: iniController,
            keyboardType: TextInputType.number,
            onChanged: (value) => newIni = int.tryParse(value) ?? person.ini,
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Speichern'),
              onPressed: () {
                editInitiative(person, newIni);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
