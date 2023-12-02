import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dsagruppen/Gruppe/GroupAmplifyService.dart';
import 'package:dsagruppen/Held/HeldAmplifyService.dart';
import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/User/UserAmplifyService.dart';
import 'package:dsagruppen/widgets/BlurredCard.dart';
import 'package:dsagruppen/widgets/ConditionalParentWidget.dart';
import 'package:dsagruppen/widgets/HeldCard.dart';
import 'package:dsagruppen/xml/HeldenParser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:xml/xml.dart';

import 'GroupUserManagement.dart';
import 'Gruppe/Gruppe.dart';
import 'Held/Held.dart';
import 'MainScaffold.dart';
import 'User/User.dart';
import 'globals.dart';
import 'model/DsaDate.dart';
import 'widgets/DsaCalendar.dart';

class GroupDetailsScreen extends StatefulWidget {
  Gruppe gruppe;

  GroupDetailsScreen({super.key, required this.gruppe});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool fetchingHelden = true;
  bool fetchingMeister = true;
  TextEditingController _notesController = TextEditingController();
  User? meister;
  StreamSubscription? heroHpSub;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.gruppe.notes;
    getIt<HeldService>().getHeldenByGroupId(widget.gruppe.uuid).then((helden) {
      if (helden != null) {
        for (var held in helden) {
          if (!widget.gruppe.helden.contains(held)) {
            widget.gruppe.helden.add(held);
          }
        }
      }
      setState(() {
        fetchingHelden = false;
      });
    }).then((_){
      widget.gruppe.helden.forEach((held) {
        if(cu == meister || cu.uuid == held.owner){
          heroHpSub = getIt<HeldAmplifyService>().subHero(held);
        }
      });
    });
    getIt<UserAmplifyService>()
        .getUser(widget.gruppe.ownerUuid).then((mu) {
          if(mu != null){
            meister = mu;
          }
      setState(() {
        fetchingMeister = false;
      });
    });
  }

  @override
  void dispose() {
    heroHpSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "Gruppendetails",
      body: fetchingHelden && widget.gruppe.helden.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(
                                Icons.badge_outlined), // Icon für 'Ausbildung'
                            title: Text('${widget.gruppe.name}')
                          ),
                          ListTile(
                            leading: Icon(Icons
                                .calendar_today_outlined), // Icon für 'Ausbildung'
                            title: Text('${widget.gruppe.datum.toString()}'),
                            trailing: isAdminGruppe() ? Icon(Icons.edit) : null,
                            onTap: () => isAdminGruppe() ? _showCalendarPopup(widget.gruppe) : null,
                          ),
                          ListTile(
                            leading: Icon(Icons.group_outlined),
                            trailing: isAdminGruppe() ? Icon(Icons.edit) : null,
                            onTap: () => isAdminGruppe() ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupUserManagement(
                                      groupId: widget.gruppe.uuid,
                                      name: widget.gruppe.name)),
                            ) : null,
                            title: FutureBuilder<List<String>?>(
                              future: getIt<GroupAmplifyService>()
                                  .gruppeUsersByGruppeId(
                                      widget.gruppe.uuid), // the async function
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircularProgressIndicator(),
                                      SizedBox(width: 10),
                                      Text('Laden...')
                                    ],
                                  );
                                  ;
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(snapshot.data != null
                                      ? '${snapshot.data!.length} Nutzer'
                                      : '0 Nutzer');
                                }
                              },
                            ),
                          ),
                          fetchingHelden ? CircularProgressIndicator() : ListTile(
                      leading: Icon(Icons
                      .gavel),
                        title: meister != null ? Text('Meister: ${meister!.name}') : Text('?')
                      ),
                          /*
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(widget.gruppe.datum.toString()),
                        IconButton(
                          icon: Icon(Icons.edit_calendar, color: Colors.red),
                          onPressed: () {
                            _showCalendarPopup(widget.gruppe);
                          },
                        ),
                      ],
                    ),
            TextField(
                      controller: _notesController,
                    )
                     */
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.gruppe.helden.length,
                    itemBuilder: (context, index) {
                      var held = widget.gruppe.helden[index];
                      //var heldNummer = widget.gruppe.helden[index].heldNummer;
                      return ConditionalParentWidget(
                          condition: !canAccessHeld(held),
                          conditionalBuilder: (Widget cchild) =>BlurredCard(child: cchild),
                        child: HeldCard(held, context, () {
                          getIt<HeldService>().deleteHeld(held.uuid).then((_) {
                            setState(() {
                              widget.gruppe.helden.removeWhere(
                                      (element) => element.uuid == held.uuid);
                              //getIt<HeldRepository>().removeHeld(heldNummer);
                              //TODO nötig? oder service?
                            });
                          });
                        }),
                      );
                    },
                  ),
                  fetchingHelden
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink()
                ],
              ),
          ),
      fab: FloatingActionButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['xml'],
          );

          if (result != null) {
            //PlatformFile file = result.files.first;
            Uint8List? fileBytes = result.files.first.bytes;
            if (fileBytes == null) {
              throw XmlParserException("Konnte die Datei nicht öffnen");
            }
            var newHeld = HeldenParser.getHeldFromXML(fileBytes!);
            newHeld.gruppeId = widget.gruppe.uuid;
            var existingHeld = widget.gruppe.helden
                .firstWhereOrNull((e) => e.heldNummer == newHeld.heldNummer);
            var shouldOverwrite = false;
            if (existingHeld != null) {
              EasyLoading.showToast('Held existert bereits in dieser Gruppe', toastPosition: EasyLoadingToastPosition.bottom);
              shouldOverwrite = await _showOverwriteHeldDialog() ?? false;
              if(shouldOverwrite == false){
                EasyLoading.showInfo("Held wird nicht überschrieben. Keine Aktion wird ausgeführt");
                return;
              }
            }
            if(shouldOverwrite){
              newHeld!.maxLp = existingHeld!.maxLp;
              newHeld!.lp = existingHeld!.lp;
              newHeld!.maxAsp = existingHeld!.maxAsp;
              newHeld!.asp = existingHeld!.asp;
              newHeld!.maxAu = existingHeld!.maxAu;
              newHeld!.au = existingHeld!.au;
              newHeld!.maxKe = existingHeld!.maxKe;
              newHeld!.ke = existingHeld!.ke;
            }
            if(existingHeld == null){
              Held? heldCreated = await getIt<HeldService>().createHeld(newHeld);
              if (heldCreated != null) {
                widget.gruppe.helden.add(newHeld);
                await getIt<GroupAmplifyService>()
                    .updateGruppe(widget.gruppe);
                setState(() {});
              }
            } else {
              await getIt<HeldService>().updateHeld(existingHeld, newHeld);
              int hIndex = widget.gruppe.helden.indexOf(existingHeld!);
              widget.gruppe.helden[hIndex] = newHeld;
              setState(() {});
            }


  /*
            if (heldCreated != null) {
              if(shouldOverwrite){
                int hIndex = widget.gruppe.helden.indexOf(existingHeld!);
                widget.gruppe.helden[hIndex] = heldCreated;
              } else {
                widget.gruppe.helden.add(newHeld);
              }

              var gp = await getIt<GroupAmplifyService>()
                  .updateGruppe(widget.gruppe);
              print("gp");
              print(gp);
              setState(() {
                //TODO was wenn held überschrieben?
                //TODO add to group? as request, in heldgpservice
                widget.gruppe.helden.add(newHeld);
              });
            } else {
              EasyLoading.showError('Fehler beim Heldenimport');
            }

   */
            //var h = await  getIt<HeldAmplifyService>().createHeld(newHeld);
            //getIt<HeldRepository>().addHeld(newHeld);
          }
        },
        child: Icon(Icons.file_upload),
        tooltip: 'Held importieren',
      ),
    );
  }

  bool isAdminGruppe() => cu.uuid == widget.gruppe.ownerUuid || cu == meister;
  bool canAccessHeld(Held h) => cu.uuid == widget.gruppe.ownerUuid || cu == meister || h.owner == cu.uuid;

  void _showCalendarPopup(Gruppe gruppe) {
    DsaDate selectedDate = DsaDate.copy(gruppe.datum);
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite, // Setzen Sie die gewünschte Breite
            child:
                DsaCalendar(gruppe.datum, selectedDate), // Ihr Kalender-Widget
          ),
          contentPadding: EdgeInsets.zero,
          actions: [
            TextButton(
              child: Text('Schließen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setLoadingButtonState) {
                return TextButton(
                  child: isLoading == true ? CircularProgressIndicator() : Text('Ok'),
                  onPressed: () async {
                    if (!isLoading) {
                      setLoadingButtonState(() => isLoading = true);
                      // Perform your async operation
                      await getIt<GroupAmplifyService>().updateGruppeDatum(
                          widget.gruppe.uuid, selectedDate.toString());
                      gruppe.datum.copyFrom(selectedDate);

                      setLoadingButtonState(() => isLoading = false);
                      setState(() {});
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showOverwriteHeldDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warnung'),
          content: Text("Held existiert bereits. Überschreiben?"),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Überschreiben'),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

}