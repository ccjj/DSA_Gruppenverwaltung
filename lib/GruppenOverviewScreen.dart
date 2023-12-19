import 'package:dsagruppen/Gruppe/GroupAmplifyService.dart';
import 'package:dsagruppen/Gruppe/GroupService.dart';
import 'package:dsagruppen/Held/HeldAmplifyService.dart';
import 'package:dsagruppen/widgets/AsyncText.dart';
import 'package:flutter/material.dart';

import 'GroupDetailsScreen.dart';
import 'Gruppe/Gruppe.dart';
import 'Gruppe/GruppeRepository.dart';
import 'globals.dart';
import 'widgets/MainScaffold.dart';

class GruppenOverviewScreen extends StatefulWidget {
  const GruppenOverviewScreen({super.key});

  @override
  GruppenOverviewScreenState createState() => GruppenOverviewScreenState();
}

class GruppenOverviewScreenState extends State<GruppenOverviewScreen> {
  List<Gruppe> gruppen =  getIt<GruppeRepository>().getAllGruppen();
  bool isDeleting = false;
  bool isLoadingGroups = true;
  String deletingId = "";


  @override
  void initState() {
    super.initState();
    getIt<GroupAmplifyService>().getGruppenByUser(cu.uuid).then((gps) {
      if(gps != null){
        getIt<GruppeRepository>().addGruppeRange(gps);
      }
      setState(() {
        isLoadingGroups = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: const Text(appName, style: TextStyle(
          fontFamily: 'Tangerine', fontSize: 46
      )),
      fab: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        child: Icon(Icons.add),
      ),
      body: isLoadingGroups ? const Center(child: CircularProgressIndicator()) : gruppen.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text('Keine Gruppen vorhanden. Füge eine hinzu!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: gruppen.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailsScreen(gruppe: gruppen[index]),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gruppen[index].name,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                            SizedBox(width: 4),
                            Text(
                              "${gruppen[index].datum}",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.sports_kabaddi, color: Colors.grey, size: 20),
                            SizedBox(width: 4),
                            AsyncText(
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              callback: () => getIt<HeldAmplifyService>().getHeldenIdsByGruppeId(gruppen[index].uuid).then((value) {
                                return value == null ? "0" : value.length.toString();
                              }),
                            ),
                          ],
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

    );
  }

  void _showAddGroupDialog() {
    TextEditingController nameController = TextEditingController();
    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Neue Gruppe hinzufügen'),
              content: TextField(
                autofocus: true,
                controller: nameController,
                decoration: InputDecoration(hintText: "Gruppenname"),
              ),
              actions: _isLoading
                  ? <Widget>[const Center(child: CircularProgressIndicator())]
                  : <Widget>[
                TextButton(
                  child: Text('Abbrechen'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Hinzufügen'),
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      setStateDialog(() => _isLoading = true);
                      await getIt<GroupService>().createGroup(nameController.text.trim());
                      setState(() {});
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


}

