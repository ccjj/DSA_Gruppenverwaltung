import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dsagruppen/Gruppe/GroupAmplifyService.dart';
import 'package:dsagruppen/Held/HeldAmplifyService.dart';
import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/MeisterPage.dart';
import 'package:dsagruppen/User/UserAmplifyService.dart';
import 'package:dsagruppen/chat/MessageAmplifyService.dart';
import 'package:dsagruppen/widgets/BlurredCard.dart';
import 'package:dsagruppen/widgets/ConditionalParentWidget.dart';
import 'package:dsagruppen/widgets/HeldCard.dart';
import 'package:dsagruppen/xml/HeldenParser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:xml/xml.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'Gruppe/Gruppe.dart';
import 'GruppeDetails/GroupDetailsCard.dart';
import 'Held/Held.dart';
import 'Held/HeldRepository.dart';
import 'User/User.dart';
import 'chat/ChatBottomBar.dart';
import 'globals.dart';
import 'widgets/MainScaffold.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Gruppe gruppe;

  const GroupDetailsScreen({super.key, required this.gruppe});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool fetchingHelden = false;
  ValueNotifier<User?> meister = ValueNotifier(null);
  StreamSubscription? heroHpSub;
  StreamSubscription? chatSub;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    heroHpSub?.cancel();
    chatSub?.cancel();
    //getIt<ChatOverlay>().gruppeId = widget.gruppe.uuid;
    if (isTest) {
      return;
    }
    getIt<UserAmplifyService>().getUser(widget.gruppe.ownerUuid).then((mu) {
      if (mu != null) {
        meister.value = mu;
      }
    });
    getIt<HeldService>().getHeldenByGroupId(widget.gruppe.uuid).then((helden) {
      if (helden != null) {
        for (var held in helden) {
          if (cu.uuid == held.owner) {
            getIt<HeldRepository>().addHeld(held);
          }
          if (!widget.gruppe.helden.contains(held)) {
            widget.gruppe.helden.add(held);
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
        if (cu == meister.value || cu.uuid == held.owner) {
          heroHpSub = getIt<HeldAmplifyService>().subHero(held);
        }
      });
    });
    chatSub =
        getIt<MessageAmplifyService>().subCreateMessage(widget.gruppe.uuid);
  }

  @override
  void dispose() {
    heroHpSub?.cancel();
    chatSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      bnb: ChatBottomBar(
        gruppeId: widget.gruppe.uuid,
        stream: messageController.stream,
      ),
      title: const Text("Gruppendetails"),
      body: fetchingHelden && widget.gruppe.helden.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(cu.uuid == widget.gruppe.ownerUuid)OutlinedButton(onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeisterPage(gruppe: widget.gruppe),
                      ),
                    ), child: Text("Zur Meister-Seite")),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GroupDetailsCard(
                          gruppe: widget.gruppe, meister: meister),
                    ),
          ResponsiveBreakpoints.of(context).largerThan(TABLET) ?
          HeldCardListDesktop()  :  HeldCardListMobile(),
                    fetchingHelden
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
      fab: ValueListenableBuilder(
          valueListenable: isChatVisible,
          builder: (context, value, child) {
            return Visibility(
              visible: !value,
              child: IconButton(
                  icon: const Icon(Icons.file_upload),
                  onPressed: () =>
                      parseAndUploadHeld(context, widget.gruppe).then((_) {
                        setState(() {});
                      })),
            );
          }),
    );
  }

  Widget HeldCardListMobile(){
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.gruppe.helden.length,
      itemBuilder: (context, index) {
        var held = widget.gruppe.helden[index];
        return ConditionalParentWidget(
          condition: !canAccessHeld(held),
          parentBuilder: (Widget cchild) =>
              BlurredCard(child: cchild),
          child: HeldCard(held, context, () {
            getIt<HeldService>()
                .deleteHeld(held.uuid)
                .then((_) {
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
    );
  }

  Widget HeldCardListDesktop(){
    return AlignedGridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      itemCount: widget.gruppe.helden.length,
      itemBuilder: (BuildContext context, int index) {
        var held = widget.gruppe.helden[index];
        return ConditionalParentWidget(
          condition: !canAccessHeld(held),
          parentBuilder: (Widget cchild) => BlurredCard(child: cchild),
          child: HeldCard(held, context, () {
            getIt<HeldService>().deleteHeld(held.uuid).then((_) {
              setState(() {
                widget.gruppe.helden.removeWhere((element) => element.uuid == held.uuid);
              });
            });
          }),
        );
      },
    );
  }

  bool isAdminGruppe() =>
      cu.uuid == widget.gruppe.ownerUuid || cu == meister.value;
  bool canAccessHeld(Held h) =>
      cu.uuid == widget.gruppe.ownerUuid ||
      cu == meister.value ||
      h.owner == cu.uuid;
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
      if (existingHeld.items.isNotEmpty) {
        //newHeld.items = existingHeld.items;
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
