import 'dart:convert';

import 'package:dsagruppen/extensions/DateTimeExtensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../GroupUserManagement.dart';
import '../Gruppe/GroupAmplifyService.dart';
import '../Gruppe/Gruppe.dart';
import '../Gruppe/UpdateGruppeInput.dart';
import '../Note/NoteAmplifyService.dart';
import '../User/User.dart';
import '../globals.dart';
import '../model/DsaDate.dart';
import '../model/Note.dart';
import '../widgets/DsaCalendar.dart';
import '../widgets/NotesExpansionTile.dart';

class GroupDetailsCard extends StatefulWidget {
  final Gruppe gruppe;
  ValueNotifier<User?> meister;

  GroupDetailsCard({Key? key, required this.gruppe, required this.meister}) : super(key: key);

  @override
  State<GroupDetailsCard> createState() => _GroupDetailsCardState();
}

class _GroupDetailsCardState extends State<GroupDetailsCard> {
  QuillController _controller = QuillController.basic();
  final FlipCardController flipController = FlipCardController();

  bool isAdminGruppe() => cu.uuid == widget.gruppe.ownerUuid || cu == widget.meister.value;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
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
                  Text(widget.gruppe.datum.toString()),
                  Visibility(
                      visible:
                      widget.gruppe.ownerUuid == cu.uuid,
                      child: IconButton(
                        onPressed: () async {
                          DsaDate newDatum = DsaDate.nextDay(widget.gruppe
                              .datum); //DsaDate(gruppe.datum.year, gruppe.datum.month, gruppe.datum.day + 1);
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
            ValueListenableBuilder(valueListenable: widget.meister, builder:
            (context, user, child) {
              if(user == null){
                return const Text('?');
              }
              return ListTile(
                leading: const Icon(Icons.gavel),
                title: user != null
                    ? Text('Meister: ${user!.name}')
                    : const Text('?'),
                contentPadding: const EdgeInsets.only(left: 16),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: () =>
                      flipController.flipcard(),
                ),
              );
            },
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
                      .gruppeUsersByGruppeId(widget.gruppe.uuid), // the async function
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
                getNoteCallback: () async {
                  Note? note = await getIt<NoteAmplifyService>().getNoteForGroup(widget.gruppe.uuid);
                  if(note == null){
                    print("NOTE IS NULL");
                    return;
                  }
                  List<dynamic> quillJson = jsonDecode(note.content);
                  _controller.document = Document.fromJson(quillJson);
                },
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
    );
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                      await getIt<GroupAmplifyService>().updateGruppeDatum(
                          gruppe.uuid, selectedDate.toString());
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
}