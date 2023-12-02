import 'package:dsagruppen/Gruppe/GroupAmplifyService.dart';
import 'package:dsagruppen/Gruppe/GroupService.dart';
import 'package:dsagruppen/Held/HeldAmplifyService.dart';
import 'package:dsagruppen/widgets/AsyncText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'GroupDetailsScreen.dart';
import 'Gruppe/Gruppe.dart';
import 'Gruppe/GruppeRepository.dart';
import 'MainScaffold.dart';
import 'globals.dart';

class GruppenOverviewScreen extends StatefulWidget {
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
      title: appName,
      fab: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        child: Icon(Icons.add),
      ),
      body: isLoadingGroups ? const Center(child: CircularProgressIndicator()) : gruppen.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('Keine Gruppen vorhanden. Füge eine hinzu!', style: TextStyle(color: Colors.grey)),
            //OutlinedButton(onPressed: () => getIt<GroupService>().getGruppen().then((value) => setState(() {})), child: Text("data"))
          ],
        ),
      )
          : ListView.builder(
        itemCount: gruppen.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            gruppen[index].name,
                            style: TextStyle(fontSize: Theme.of(context).textTheme.headlineLarge?.fontSize),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: isDeleting && deletingId == gruppen[index].uuid ? const CircularProgressIndicator() : Icon(Icons.delete, color: Colors.red, size: (Theme.of(context).textTheme.headlineLarge!.fontSize! * 1)),
                          onPressed: isDeleting ? null : () async {

                            setState(() {
                              isDeleting = true;
                              deletingId = gruppen[index].uuid;
                            });
                            var owner = gruppen[index].ownerUuid;
                            if(cu.uuid != owner){
                              EasyLoading.showError("Keine Rechte zum Löschen");
                              return;
                            }
                            //var isDeleted = await deleteGruppe(gruppen[index].uuid);
                            //TODO DI, gruppe definieren
                            var isDeleted = await getIt<GroupService>().deleteGruppe(gruppen[index].uuid);
                            if(isDeleted) {
                              setState(() {});
                            } else {
                              EasyLoading.showError("Konnte die Gruppe nicht löschen. Verfügst du über die Rechte dazu und bist online?");
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Colors.grey, size: (Theme.of(context).textTheme.bodySmall!.fontSize! * 1.5)),
                            Text("${gruppen[index].datum}", style: TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize, color: Colors.grey[700])),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons., color: Colors.grey, size: (Theme.of(context).textTheme.bodySmall!.fontSize! * 1.5)),
                            //Text("${gruppen[index].helden.length}", style: TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize, color: Colors.grey[700]))
                            //Text("${gruppen[index].helden.length}", style: TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize, color: Colors.grey[700])),
                            AsyncText(
                                style: TextStyle(fontSize: Theme.of(context).textTheme.bodySmall?.fontSize, color: Colors.grey[700]),
                                callback: ()=> getIt<HeldAmplifyService>().getHeldenIdsByGruppeId(gruppen[index].uuid).then((value) {
                              if(value == null){
                                return "0";
                              }
                              return value!.length.toString();
                            })),
                          ],
                        ),
                      ],
                    )
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

