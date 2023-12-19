import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dsagruppen/Gruppe/GroupAmplifyService.dart';
import 'package:dsagruppen/Gruppe/UpdateGruppeInput.dart';
import 'package:dsagruppen/Held/HeldAmplifyService.dart';
import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/User/UserAmplifyService.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/chat/MessageAmplifyService.dart';
import 'package:dsagruppen/extensions/DateTimeExtensions.dart';
import 'package:dsagruppen/model/Note.dart';
import 'package:dsagruppen/widgets/BlurredCard.dart';
import 'package:dsagruppen/widgets/ConditionalParentWidget.dart';
import 'package:dsagruppen/widgets/HeldCard.dart';
import 'package:dsagruppen/widgets/NotesExpansionTile.dart';
import 'package:dsagruppen/xml/HeldenParser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import 'GroupUserManagement.dart';
import 'Gruppe/Gruppe.dart';
import 'Held/Held.dart';
import 'Note/NoteAmplifyService.dart';
import 'User/User.dart';
import 'chat/ChatOverlay.dart';
import 'globals.dart';
import 'model/DsaDate.dart';
import 'widgets/DsaCalendar.dart';
import 'widgets/MainScaffold.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Gruppe gruppe;

  const GroupDetailsScreen({super.key, required this.gruppe});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool fetchingHelden = false; //no testmode, set to true
  bool fetchingMeister = false; //no testmode, set to true
  //TextEditingController _notesController = TextEditingController();
  User? meister;
  StreamSubscription? heroHpSub;
  StreamSubscription? chatSub;
  final flipController = FlipCardController();
  QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    heroHpSub?.cancel();
    chatSub?.cancel();
    getIt<ChatOverlay>().gruppeId = widget.gruppe.uuid;
    Future.delayed(const Duration(milliseconds: 100), () {
      isChatVisible.value = true;
    });
    if (isTest) {
      return;
    }
    getIt<HeldService>().getHeldenByGroupId(widget.gruppe.uuid).then((helden) {
      if (helden != null) {
        for (var held in helden) {
          if (!widget.gruppe.helden.contains(held)) {
            widget.gruppe.helden.add(held);
            //print(held.uuid);
            //print(widget.gruppe.helden.first.uuid);
          }
        }
      }

      widget.gruppe.helden.sort((a, b) {
        if (a.owner == cu.uuid) return -1;
        if (b.owner == cu.uuid) return 1;
        return a.uuid.compareTo(b.uuid);
      });
      setState(() {
        fetchingHelden = false;
      });
    }).then((_) {
      widget.gruppe.helden.forEach((held) {
        if (cu == meister || cu.uuid == held.owner) {
          heroHpSub = getIt<HeldAmplifyService>().subHero(held);
        }
      });
    });
    chatSub =
        getIt<MessageAmplifyService>().subCreateMessage(widget.gruppe.uuid);
    getIt<UserAmplifyService>().getUser(widget.gruppe.ownerUuid).then((mu) {
      if (mu != null) {
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
    chatSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: const Text("Gruppendetails"),
      body: fetchingHelden && widget.gruppe.helden.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTest)
                    TextButton(
                        onPressed: () {
                          isChatVisible.value = !isChatVisible.value;
                          //chatOverlay.switchOverlay(context);
                        },
                        child: const Text("show")),
                  if (isTest)
                    TextButton(
                        onPressed: () {
                          messageController.add(ChatMessage(
                              messageContent: "messageContent",
                              groupId: widget.gruppe.uuid,
                              timestamp: DateTime.now(),
                              ownerId: cu.uuid,
                              isPrivate: true));
                        },
                        child: const Text("TEST")),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlipCard(
                      animationDuration: const Duration(milliseconds: 300),
                      controller: flipController,
                      rotateSide: RotateSide.right,
                      axis: FlipAxis.vertical,
                      frontWidget: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.badge_outlined),
                              title: Text('${widget.gruppe.name}'),
                              contentPadding: const EdgeInsets.only(left: 16),
                              trailing: IconButton(
                                icon: const Icon(Icons.info_outline_rounded),
                                onPressed: () => flipController.flipcard(),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.calendar_today_outlined),
                              title: Row(
                                children: [
                                  Text('${widget.gruppe.datum.toString()}'),
                                  Visibility(
                                      visible:
                                          widget.gruppe.ownerUuid == cu.uuid,
                                      child: IconButton(
                                        onPressed: () async {
                                          DsaDate newDatum = DsaDate.nextDay(widget
                                              .gruppe
                                              .datum); //DsaDate(widget.gruppe.datum.year, widget.gruppe.datum.month, widget.gruppe.datum.day + 1);
                                          await getIt<GroupAmplifyService>()
                                              .updateGruppeDatum(
                                                  widget.gruppe.uuid,
                                                  newDatum.toString());
                                          widget.gruppe.datum
                                              .copyFrom(newDatum);
                                          setState(() {});
                                        },
                                        icon: const RotatedBox(
                                            quarterTurns: 3,
                                            child: Icon(Icons.chevron_right)),
                                      )
                                      //child: const Text("△", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                                      ),
                                  Visibility(
                                      visible:
                                          widget.gruppe.ownerUuid == cu.uuid,
                                      child: IconButton(
                                        onPressed: () async {
                                          DsaDate newDatum =
                                              DsaDate.previousDay(
                                                  widget.gruppe.datum);
                                          await getIt<GroupAmplifyService>()
                                              .updateGruppeDatum(
                                                  widget.gruppe.uuid,
                                                  newDatum.toString());
                                          widget.gruppe.datum
                                              .copyFrom(newDatum);
                                          setState(() {});
                                        },
                                        icon: const RotatedBox(
                                            quarterTurns: 5,
                                            child: Icon(Icons.chevron_right)),
                                      ) //const Text("▽", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                                      ),
                                ],
                              ),
                              trailing:
                                  isAdminGruppe() ? const Icon(Icons.edit) : null,
                              onTap: () => isAdminGruppe()
                                  ? _showCalendarPopup(widget.gruppe)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      backWidget: Card(
                        child: Column(
                          children: [
                            fetchingHelden
                                ? const CircularProgressIndicator()
                                : ListTile(
                                    leading: const Icon(Icons.gavel),
                                    title: meister != null
                                        ? Text('Meister: ${meister!.name}')
                                        : const Text('?'),
                                    contentPadding: const EdgeInsets.only(left: 16),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.info_outline_rounded),
                                      onPressed: () =>
                                          flipController.flipcard(),
                                    ),
                                  ),
                            ListTile(
                              leading: const Icon(Icons.calendar_month_rounded),
                              title:
                                  Text('Nächstes Spieldatum: ${widget.gruppe.treffenAm != null ? widget.gruppe.treffenAm!.toGermanDate() : '?'}'),
                              trailing:  isAdminGruppe() ? const Icon(Icons.edit) : null,
                                onTap: isAdminGruppe() ?  () => selectDate(context, widget.gruppe.treffenAm).then((value) {
                                  if(value != null) {
                                    getIt<GroupAmplifyService>().updateGruppeFromInput(UpdateGruppeInput(id: widget.gruppe.uuid, treffenAm: value));
                                    setState(() {
                                      widget.gruppe.treffenAm = value;
                                    });
                                  }
                                }) : null
                              ),
                            if (!isTest)
                              ListTile(
                                leading: const Icon(Icons.group_outlined),
                                trailing:
                                    isAdminGruppe() ? const Icon(Icons.edit) : null,
                                onTap: () => isAdminGruppe()
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GroupUserManagement(
                                                    groupId: widget.gruppe.uuid,
                                                    name: widget.gruppe.name)),
                                      )
                                    : null,
                                title: FutureBuilder<List<String>?>(
                                  future: getIt<GroupAmplifyService>()
                                      .gruppeUsersByGruppeId(widget
                                          .gruppe.uuid), // the async function
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
                            NotesExpansionTile(
                                controller: _controller,
                                gruppe: widget.gruppe,
                                saveCallback: (documentString) async {
                                  if (widget.gruppe.ownerUuid != cu.uuid) {
                                    EasyLoading.showToast(
                                        "Notizen können aktuell nur vom Meister gespeichert werden");
                                    return;
                                  }

                                  var shouldCreate = false;
                                  Note? note = await getIt<NoteAmplifyService>()
                                      .getNoteForGroup(widget.gruppe.uuid);
                                  if (note == null) {
                                    print("NOTE IS NULL");
                                    note = Note(
                                        uuid: const Uuid().v4(),
                                        content: documentString);
                                    shouldCreate = true;
                                  }
                                  var saved = await getIt<NoteAmplifyService>()
                                      .saveNote(note.uuid, documentString,
                                          shouldCreate);
                                  if (saved) {
                                    print("note ${note.uuid}");
                                    var gpSaved =
                                        await getIt<GroupAmplifyService>()
                                            .updateGroupWithNote(
                                                widget.gruppe.uuid, note.uuid);
                                    if (gpSaved) {
                                      EasyLoading.showToast(
                                          "Notiz wurde gespeichert: $gpSaved");
                                    }
                                  }
                                })
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.gruppe.helden.length,
                    itemBuilder: (context, index) {
                      var held = widget.gruppe.helden[index];
                      //var heldNummer = widget.gruppe.helden[index].heldNummer;
                      return ConditionalParentWidget(
                        condition: !canAccessHeld(held),
                        conditionalBuilder: (Widget cchild) =>
                            BlurredCard(child: cchild),
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
      //bnb: BottomChatBar(gruppe: widget.gruppe, setStateCallback: () => setState( () {} ), showBs: isChatVisible,),
      //bs: ChatBar(),
      fab: IconButton(
          icon: const Icon(Icons.file_upload),
          onPressed: () => parseAndUploadHeld(context, widget.gruppe).then((_) {
                setState(() {});
              })),
    );
  }

  bool isAdminGruppe() => cu.uuid == widget.gruppe.ownerUuid || cu == meister;
  bool canAccessHeld(Held h) =>
      cu.uuid == widget.gruppe.ownerUuid || cu == meister || h.owner == cu.uuid;

  void _showCalendarPopup(Gruppe gruppe) {
    DsaDate selectedDate = DsaDate.copy(gruppe.datum);
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: DsaCalendar(gruppe.datum, selectedDate),
          ),
          contentPadding: EdgeInsets.zero,
          actions: [
            TextButton(
              child: const Text('Schließen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            StatefulBuilder(
              builder:
                  (BuildContext context, StateSetter setLoadingButtonState) {
                return TextButton(
                  child: isLoading == true
                      ? const CircularProgressIndicator()
                      : const Text('Ok'),
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
}

Future<bool?> _showOverwriteHeldDialog() async {
  return showDialog<bool>(
    context: navigatorKey.currentState!.overlay!.context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Warnung'),
        content: const Text("Held existiert bereits. Überschreiben?"),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Überschreiben'),
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

Future<void> parseAndUploadHeld(BuildContext context, Gruppe gruppe) async {
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
    var newHeld = HeldenParser.getHeldFromXML(fileBytes);
    newHeld.gruppeId = gruppe.uuid;
    var existingHeld = gruppe.helden
        .firstWhereOrNull((e) => e.heldNummer == newHeld.heldNummer);
    var shouldOverwrite = false;
    if (existingHeld != null) {
      EasyLoading.showToast('Held existert bereits in dieser Gruppe',
          toastPosition: EasyLoadingToastPosition.bottom);
      shouldOverwrite = await _showOverwriteHeldDialog() ?? false;
      if (shouldOverwrite == false) {
        EasyLoading.showInfo(
            "Held wird nicht überschrieben. Keine Aktion wird ausgeführt");
        return;
      }
    }
    if (shouldOverwrite) {
      newHeld.uuid = existingHeld!.uuid;
      newHeld.maxLp = existingHeld.maxLp;
      newHeld.lp = existingHeld.lp;
      newHeld.maxAsp = existingHeld.maxAsp;
      newHeld.asp = existingHeld.asp;
      newHeld.maxAu = existingHeld.maxAu;
      newHeld.au = existingHeld.au;
      newHeld.maxKe = existingHeld.maxKe;
      newHeld.ke = existingHeld.ke;
      if(existingHeld.items.isNotEmpty){
        newHeld.items = existingHeld.items;
      }
    }
    if (existingHeld == null) {
      Held? heldCreated = await getIt<HeldService>().createHeld(newHeld);
      if (heldCreated != null) {
        gruppe.helden.add(newHeld);
        await getIt<GroupAmplifyService>().updateGruppe(gruppe);
      }
    } else {
      await getIt<HeldService>().updateHeld(existingHeld, newHeld);
      int hIndex = gruppe.helden.indexOf(existingHeld);
      gruppe.helden[hIndex] = newHeld;
    }
  }
  return;
}

Future<DateTime?> selectDate(BuildContext context, DateTime? initialDate) async {
  DateTime selectedDate = DateTime.now();
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime.now(), // Adjust based on your requirement
    lastDate: DateTime(2100),  // Adjust based on your requirement
  );

  if (picked != null && picked != selectedDate) {
    selectedDate = picked;
    return selectedDate;
  }
  return null;
}