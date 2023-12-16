import 'package:dsagruppen/Held/Held.dart';
import 'package:dsagruppen/extensions/IterableExtensions.dart';
import 'package:dsagruppen/rules/RollCalculator.dart';
import 'package:dsagruppen/rules/RuleProvider.dart';
import 'package:flutter/material.dart';

import '../skills/ISkill.dart';
import 'AnimatedIconButton.dart';
import 'AsyncText.dart';

class SearchableDataTable extends StatefulWidget {
  final List<String>? stringList;
  final Map<String, int>? stringMap;
  final String col1Label;
  final String? col2Label;
  final bool isEditable;
  final Held held;
  final Function(String, int)? rollCallback;

  //check if col2 != null when stringmap is given. check if either stringmap or list is set. and not both
  SearchableDataTable(
      {Key? key,
        this.stringList,
        this.stringMap,
        required this.col1Label,
        this.col2Label,
        this.isEditable = false,
        this.rollCallback, required this.held})
      : super(key: key);

  @override
  _SearchableDataTableState createState() => _SearchableDataTableState();
}

class _SearchableDataTableState extends State<SearchableDataTable> {
  String searchString = '';
  final TextEditingController _addController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<DataColumn> columns;
    List<DataRow> rows;

    if (widget.stringList != null) {
      //columns = [DataColumn(label: Text(widget.col1Label))];
      columns = [const DataColumn(label: SizedBox())];
      rows = _buildListRows(widget.stringList!);
    } else if (widget.stringMap != null) {
      columns = [
        DataColumn(label: Text(widget.col1Label)),
        DataColumn(label: Text(widget.col2Label!))
      ];
      rows = _buildMapRows(widget.stringMap!);
    } else {
      columns = [];
      rows = [];
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) => setState(() => searchString = value),
            decoration: const InputDecoration(
              labelText: 'Suche',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Visibility(
          visible: widget.isEditable,
          child: Padding(
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
        ),
        SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowHeight:
            0.0, //widget.stringList != null ? 0.0 : Theme.of(context).dataTableTheme.headingRowHeight,
            columns: columns,
            rows: rows,
          ),
        ),
      ],
    );
  }

  void _handleAdd() {
    //TODO save items
    if (widget.stringList != null) {
      setState(() => widget.stringList!.add(_addController.text));
    } else if (widget.stringMap != null) {
      var parts = _addController.text.split(':');
      if (parts.length == 1) {
        setState(() => widget.stringMap![_addController.text] = 1);
      } else if (parts.length == 2) {
        setState(
                () => widget.stringMap![parts[0]] = int.tryParse(parts[1]) ?? 1);
      }
    }
    _addController.clear();
  }


  List<DataRow> _buildListRows(List<String> list) {
    return list
        .where(
            (item) => item.toLowerCase().contains(searchString.toLowerCase()))
        .indexedMap((index, item) => DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (!index.isOdd) {
            return Theme.of(context).highlightColor.withOpacity(0.15);
          }
          return null; // Use default color for even rows
        },
      ),
      cells: [
        DataCell(
          onTap: widget.isEditable
              ? () => _showEditDialog(item, null).then((_) => setState(()=>{}))
              : null,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item),
              if (widget.isEditable)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeListItem(item),
                ),
              if (widget.rollCallback != null)
                AnimatedIconButton(
                  icon: (Icons.casino_outlined),
                  onTap: () => widget.rollCallback!(item, 0),
                )
            ],
          ),
        ),
      ],
    ))
        .toList();
  }

  List<DataRow> _buildMapRows(Map<String, int> map) {
    var filteredEntries = map.entries
        .where((entry) =>
        entry.key.toLowerCase().contains(searchString.toLowerCase()))
        .toList(); // Convert to list to use the index in the map

    return List.generate(filteredEntries.length, (index) {
      var entry = filteredEntries[index];
      ValueNotifier modificator = ValueNotifier(0);
      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (index.isEven) {
              return Theme.of(context).highlightColor.withOpacity(0.15);
            }
            return null; // Default color for odd rows
          },
        ),
        cells: [
          DataCell(
            Text(entry.key),
          ),
          DataCell(
            onTap: widget.isEditable
                ? () => _showEditDialog(entry.key, entry.value)
                : null,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${entry.value}'),
                  ),
                  if (!widget.isEditable)
                  VerticalDivider(),
                  if (!widget.isEditable)
                  SizedBox(
                    width: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.zero
                      ),
                      onChanged: (newValue) {
                        modificator.value = int.tryParse(newValue) ?? 0;
                      },
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (widget.isEditable)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeMapItem(entry.key),
                    ),
                  if (widget.rollCallback != null)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedIconButton(
                            icon: (Icons.casino_outlined),
                            onTap: () => widget.rollCallback!(entry.key, entry.value),
                          ),
                          ValueListenableBuilder(
                              valueListenable: modificator,
                              builder: (context, value, child)  {
                                return AsyncText(callback: () {
                                  ISkill? skill = RuleProvider.getSkillByName(entry.key);
                                  int mod = RuleProvider.getModificator(widget.held, skill, modificator.value);
                                  return RollCalculator.calcChance(widget.held, RuleProvider.getSkillByName(entry.key), mod);
                                }
                                    , showSpinner: false
                                );
                              }
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      );
    });
  }

  Future<void> _showEditDialog(String key, int? value) async {
    TextEditingController editController =
    TextEditingController(text: value?.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Entry'),
          content: TextField(controller: editController, autofocus: true),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (widget.stringList != null) {
                  setState(() {
                    int index = widget.stringList!.indexOf(key);
                    if (index != -1) {
                      widget.stringList![index] = editController.text;
                    }
                  });
                } else if (widget.stringMap != null) {
                  setState(() {
                    widget.stringMap![key] =
                        int.tryParse(editController.text) ?? 0;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeListItem(String item) {
    setState(() {
      widget.stringList?.remove(item);
    });
  }

  void _removeMapItem(String key) {
    setState(() {
      widget.stringMap?.remove(key);
    });
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }
}
