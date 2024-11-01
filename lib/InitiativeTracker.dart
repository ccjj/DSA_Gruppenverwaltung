import 'package:dsagruppen/widgets/PlusMinusButton.dart';
import 'package:flutter/material.dart';

import 'Held/FightEntity.dart';
import 'Held/Held.dart';
import 'Held/Person.dart';

class InitiativeTracker extends StatefulWidget {
  List<Person> helden;

  InitiativeTracker(this.helden);
  @override
  _InitiativeTrackerState createState() => _InitiativeTrackerState();
}

class _InitiativeTrackerState extends State<InitiativeTracker> {

  TextEditingController iniController = TextEditingController();
  List<Person> persons = [];
  int runde = 1;

  @override
  void initState() {
    super.initState();
    persons.addAll(widget.helden);
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
    return Column(
      children: [
        Row(
          children: [
            Text("Runde: $runde"),
            IconButton(
              icon: Icon(Icons.next_plan),
              onPressed: nextRound,
              tooltip: 'Nächste Runde',
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _showAddPersonDialog,
              tooltip: 'Neue Person hinzufügen',
            ),
            TextButton(onPressed: null, child: Text("reset")),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Niedrige LP Regeln"),
                Checkbox(value: false, onChanged: null),
              ],
            )
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              return GestureDetector(
                onTap: () => _showEditDialog(person),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person.name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Initiative: ${person.ini}/${person.baseIni}'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: PlusMinusButton(
                                title: 'Lebenspunkte (LP)',
                                enabled: true,
                                leading: const Icon(Icons.favorite, color: Colors.red),
                                value: person.lp,
                                maxValue: person.maxLp.value,
                                onValueChanged: (newVal) {
                                  setState(() {
                                    person.lp.value = newVal;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              fit: FlexFit.loose,
                              child: PlusMinusButton(
                                title: 'Ausdauer (AU)',
                                enabled: true,
                                leading: const Icon(Icons.directions_run, color: Colors.amber),
                                value: person.au,
                                maxValue: person.maxAu.value,
                                onValueChanged: (newVal) {
                                  setState(() {
                                    person.au.value = newVal;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            if (person.heldNummer.isEmpty)
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deletePerson(person),
                              ),
                          ],
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
    );
  }


  void _deletePerson(Person person){
    persons.removeWhere((p) => p.uuid == person.uuid);
    setState(() {
    });
  }

  void _showAddPersonDialog() {
    String name = '';
    int ini = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Neue Person hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Initiative'),
                keyboardType: TextInputType.number,
                onChanged: (value) => ini = int.tryParse(value) ?? 0,
              ),
              // Hier kannst du weitere Felder für die anderen Eigenschaften hinzufügen
            ],
          ),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Hinzufügen'),
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
                    ws: 5, initialLp: 20, initialMaxLp: 20, initialAsp: 0, initialMaxAsp: 0, initialAu: 24, initialMaxAu: 24,
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

  void _showEditDialog(Person person) {
    int newIni = person.ini;
    iniController.text = newIni.toString();
    iniController.selection = TextSelection(baseOffset: 0, extentOffset: iniController.value.text.length);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Initiative bearbeiten'),
          content: TextFormField(autofocus: true,
            decoration: InputDecoration(labelText: 'Neue Initiative'),
            controller: iniController,
            keyboardType: TextInputType.number,
            onChanged: (value) => newIni = int.tryParse(value) ?? person.ini,
          ),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Speichern'),
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
