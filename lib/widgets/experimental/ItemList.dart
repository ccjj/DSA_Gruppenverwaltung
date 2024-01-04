import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/Held/UpdateHeldInput.dart';
import 'package:flutter/material.dart';

import '../../Held/Held.dart';
import '../../globals.dart';
import '../../model/Item.dart';

class ItemList extends StatefulWidget {
  Held held;

  ItemList({super.key, required this.held});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final TextEditingController _addController = TextEditingController();
  String searchString = "";
  final heldService = getIt<HeldService>();
  late Function updateItems;
  bool get isOwner => widget.held.owner == cu.uuid;
  TextEditingController textController = TextEditingController();

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
    ))..sort((a, b) => a.name.compareTo(b.name));

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: textController,
              onChanged: (value) => setState(() => searchString = value),
              decoration: InputDecoration(
                labelText: 'Suche',
                  fillColor: Colors.grey.withOpacity(0.1),
                  filled: true,
                suffix: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: (){
                    setState(() {
                      searchString = "";
                      textController.clear();
                    });
                  },
                ),
                //suffixIcon: const Icon(Icons.search),
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
              padding: EdgeInsets.zero,
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
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: InkWell(
                                onTap: isOwner ? () => _showEditDialog(citem.name, "Item-Name").then((value) {
                                  if(value == null) return;
                                  citem.name = value;
                                  updateItems.call();
                                  setState(() {});
                                }) : null,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Tooltip(
                                        message: citem.name,
                                        child: Text(citem.name)))),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: isOwner ? () => _showEditDialog(citem.anzahl.toString(), "Anzahl").then((value) {
                                if(value == null) return;
                                int? neuAnzahl = int.tryParse(value);
                                if(neuAnzahl == null) return;
                                citem.anzahl = neuAnzahl;
                                updateItems.call();
                                setState(() {});
                              }) : null,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("${citem.anzahl}x")),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: InkWell(
                              onTap: isOwner ? () => _showEditDialog(citem.beschreibung ?? '', "Beschreibung").then((value) {
                                if(value == null) return;
                                citem.beschreibung = value;
                                updateItems.call();
                                setState(() {});
                              }) : null,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Tooltip(
                                  message: citem.beschreibung ?? 'keine Beschreibung',
                                  child: Text(
                                    citem.beschreibung ?? 'keine Beschreibung',
                                    style: citem.beschreibung == null ? const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic) : const TextStyle(),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.held.owner == cu.uuid,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                var cindex = items.indexOf(citem);
                                items.removeAt(cindex);
                                updateItems.call();
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
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
    var parts = _addController.text.split(':');
    if (parts.length == 1) {
      setState(
          () => widget.held.items.add(Item(name: _addController.text, anzahl: 1)
              ));
    } else if (parts.length == 2) {
      setState(() {
        widget.held.items
            .add(Item(name: parts[0], anzahl: int.tryParse(parts[1]) ?? 1)
                );
      });
    }
    updateItems.call();
    _addController.clear();
  }

  Future<String?> _showEditDialog(String? value, String colName) async {
    TextEditingController editController =
    TextEditingController(text: value?.toString() ?? '');
    final result = await showDialog(
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
    return result;
  }

}
