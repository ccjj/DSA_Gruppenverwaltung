import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/Held/UpdateHeldInput.dart';
import 'package:flutter/material.dart';

import '../../Held/Held.dart';
import '../../globals.dart';
import '../../model/Item.dart';

class ItemList extends StatefulWidget {
  Held held;

  ItemList({required this.held});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final TextEditingController _addController = TextEditingController();
  String searchString = "";
  final heldService = getIt<HeldService>();
  late Function updateItems;

  @override
  void initState() {
    super.initState();
    updateItems = () {
      getIt<HeldService>().updateHeldFromInput(UpdateHeldInput(id: widget.held.uuid, items: widget.held.items));
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Item> items = widget.held.items;

    List<Item> filteredItems = List.from(items.where(
      (entry) => entry.name.toLowerCase().contains(searchString.toLowerCase()),
    ));

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => searchString = value),
              decoration: InputDecoration(
                labelText: 'Suche',
                  fillColor: Colors.grey.withOpacity(0.1),
                  filled: true,
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: const InputDecoration(
                        hintText: 'Hinzufügen mit Name:Anzahl'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _handleAdd,
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Theme(
            data: Theme.of(context).copyWith(
              textTheme: TextTheme(
                bodyMedium: Theme.of(context).textTheme.labelLarge,
                bodySmall: Theme.of(context).textTheme.labelLarge,
                bodyLarge: Theme.of(context).textTheme.labelLarge,
                labelMedium: Theme.of(context).textTheme.labelLarge,
                labelLarge: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filteredItems.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final citem = filteredItems.elementAt(index);
                return Container(
                  key: ValueKey("item$index"),
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  color: index.isEven
                      ? Theme.of(context).highlightColor.withOpacity(0.15)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: InkWell(
                              onTap: () => _showEditDialog(citem.name, "Item-Name").then((value) {
                                if(value == null) return;
                                filteredItems.elementAt(index).name = value;
                                //todo update
                              }),
                              child: Text(citem.name)),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () => _showEditDialog(citem.anzahl.toString(), "Anzahl").then((value) {
                              if(value == null) return;
                              int? neuAnzahl = int.tryParse(value);
                              if(neuAnzahl == null) return;
                              citem.anzahl = neuAnzahl;
                              updateItems.call();
                            }),
                            child: Text(citem.anzahl.toString()),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () => _showEditDialog(citem.beschreibung ?? '', "Beschreibung").then((value) {
                              if(value == null) return;
                              filteredItems.elementAt(index).beschreibung = value;
                              updateItems.call();
                            }),
                            child: Text(
                              citem.beschreibung ?? '-',
                              style: citem.beschreibung == null ? TextStyle(color: Colors.grey) : TextStyle(),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: widget.held.owner == cu.uuid,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              items.removeAt(index);
                              updateItems.call();
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleAdd() {
    //TODO save items
    var parts = _addController.text.split(':');
    if (parts.length == 1) {
      setState(
          () => widget.held.items.add(Item(name: _addController.text, anzahl: 1)
              //TODO add if not
              ));
    } else if (parts.length == 2) {
      setState(() {
        widget.held.items
            .add(Item(name: parts[0], anzahl: int.tryParse(parts[1]) ?? 1)
                //TODO add if not
                );
      });
    }
    updateItems.call();
    _addController.clear();
  }

  Future<String?> _showEditDialog(String? value, String colName) async {
    TextEditingController editController =
    TextEditingController(text: value?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$colName bearbeiten"),
          content: TextField(controller: editController, autofocus: true),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(editController.text);
              },
            ),
          ],
        );
      },
    );
  }

}
