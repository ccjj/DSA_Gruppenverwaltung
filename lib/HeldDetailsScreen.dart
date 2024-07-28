import 'dart:convert';
import 'dart:math';

import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/chat/MessageAmplifySubscriptionService.dart';
import 'package:dsagruppen/rules/RollManager.dart';
import 'package:dsagruppen/widgets/AnimatedIconButton.dart';
import 'package:dsagruppen/widgets/ConditionalParentWidget.dart';
import 'package:dsagruppen/widgets/NotesExpansionTile.dart';
import 'package:dsagruppen/widgets/PlusMinusButton.dart';
import 'package:dsagruppen/widgets/SearchableDataTable.dart';
import 'package:dsagruppen/widgets/experimental/ItemList.dart';
import 'package:dsagruppen/widgets/experimental/SkillList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:responsive_framework/responsive_grid.dart';
import 'package:uuid/uuid.dart';

import 'Held/Held.dart';
import 'Held/HeldAmplifyService.dart';
import 'Held/UpdateHeldInput.dart';
import 'HeldDetailScreen/AttributeListWidget.dart';
import 'HeldDetailScreen/BasisWerteTile.dart';
import 'HeldDetailScreen/CardWithTitle.dart';
import 'HeldDetailScreen/HeroDetailCard.dart';
import 'HeldDetailScreen/ExpansionTileWithTitle.dart';
import 'HeldDetailScreen/VitalWerteColumn.dart';
import 'Note/NoteAmplifyService.dart';
import 'actions/ActionSource.dart';
import 'actions/ActionStack.dart';
import 'chat/BottomBar/ChatBottomBar.dart';
import 'chat/ChatOverlay.dart';
import 'globals.dart';
import 'model/Note.dart';
import 'widgets/MainScaffold.dart';

class HeldDetailsScreen extends StatefulWidget {
  final Held held;

  const HeldDetailsScreen({super.key, required this.held});

  @override
  State<HeldDetailsScreen> createState() => HeldDetailsScreenState();
}

class HeldDetailsScreenState extends State<HeldDetailsScreen> {
  var isTalentsExpanded = ValueNotifier(false);
  var isZauberExpanded = ValueNotifier(false);
  static const double largeCardHeight = 400;
  static const pageTitle = "Heldendetails";

  @override
  void initState() {
    super.initState();
    getIt<ChatOverlay>().gruppeId = widget.held.gruppeId;
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).largerThan(TABLET)) {
      return MainScaffold(
          title: const Text(pageTitle),
          body: DesktopView(largeCardHeight: largeCardHeight, held: widget.held));
    }
    return MainScaffold(
      title: const Text(pageTitle),
      bnb: (ResponsiveBreakpoints.of(context).largerThan(TABLET))
          ? null
          : ChatBottomBar(
              gruppeId: widget.held.gruppeId, stream: messageController.stream),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                switch (index) {
                  case 0:
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HeroDetailCard(held: widget.held),
                    );
                  case 1:
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: VitalWerteColumn(held: widget.held),
                      ),
                    );
                  default:
                    return null;
                }
              },
              childCount: 2,
            ),
          ),
          SliverToBoxAdapter(
            child: ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              title: const Text('Eigenschaften'),
              children: [AttributeListWidget(held: widget.held)],
            ),
          ),
          SliverToBoxAdapter(
            child: BasiswerteTile(held: widget.held),
          ),
          SliverToBoxAdapter(
            child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: const Text('Vor-/Nachteile'),
                children: [
                  SearchableDataTable(
                      held: widget.held,
                      stringList: widget.held.vorteile,
                      col1Label: 'Vorteil')
                ]),
          ),
          SliverToBoxAdapter(
            child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: const Text('Sonderfertigkeiten'),
                children: [
                  SearchableDataTable(
                      held: widget.held,
                      stringList: widget.held.sf,
                      col1Label: 'Sonderfertigkeit')
                ]),
          ),
          if (isTalentsExpanded.value)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color:
                            Theme.of(context).dividerColor), // Only top border
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                key: talentKey,
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: const Text('Talente'),
                children: const [],
                onExpansionChanged: (bool expanded) {
                  isTalentsExpanded.value = !isTalentsExpanded.value;
                  setState(() {});
                },
              ),
            ),
          ),
          if (isTalentsExpanded.value)
            SkillList(
                hasSliverParent: true,
                held: widget.held,
                skillMap: widget.held.talents,
                rollCallback: (talentName, taw, penalty) {
                  String msg = getIt<RollManager>()
                      .rollTalent(widget.held, talentName, penalty);
                  if (widget.held.owner == cu.uuid) {
                    getIt<MessageAmplifySubscriptionService>()
                        .createMessage(msg, widget.held.gruppeId, cu.uuid);
                  } else {
                    messageController.add(ChatMessage(
                        messageContent: msg,
                        groupId: widget.held.gruppeId,
                        timestamp: DateTime.now(),
                        ownerId: cu.uuid,
                        isPrivate: true));
                  }
                }),
          if (isTalentsExpanded.value)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color:
                            Theme.of(context).dividerColor), // Only top border
                  ),
                ),
              ),
            ),
          if (isZauberExpanded.value)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color:
                            Theme.of(context).dividerColor), // Only top border
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                key: zauberKey,
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: const Text('Zauber'),
                maintainState: true,
                children: const [],
                onExpansionChanged: (bool expanded) {
                  isZauberExpanded.value = !isZauberExpanded.value;
                  setState(() {});
                },
              ),
            ),
          ),
          if (isZauberExpanded.value)
            SkillList(
                hasSliverParent: true,
                held: widget.held,
                skillMap: widget.held.zauber,
                rollCallback: (talentName, taw, penalty) {
                  String msg = getIt<RollManager>()
                      .rollZauber(widget.held, talentName, penalty);
                  if (widget.held.owner == cu.uuid) {
                    getIt<MessageAmplifySubscriptionService>()
                        .createMessage(msg, widget.held.gruppeId, cu.uuid);
                  } else {
                    messageController.add(ChatMessage(
                        messageContent: msg,
                        groupId: widget.held.gruppeId,
                        timestamp: DateTime.now(),
                        ownerId: cu.uuid,
                        isPrivate: true));
                  }
                }),
          if (isZauberExpanded.value)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color:
                            Theme.of(context).dividerColor), // Only top border
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              title: const Text('Items'),
              children: [ItemList(held: widget.held)],
            ),
          ),
        ],
      ),
    );
  }
}


class DesktopView extends StatelessWidget {
  DesktopView({
    super.key,
    required this.largeCardHeight,
    required this.held,
  });

  final double largeCardHeight;
  final Held held;
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {

    List<Widget> children = [
      HeroDetailCard(held: held),
      CardWithTitle(
        title: "Vitalwerte",
        child: VitalWerteColumn(held: held),
      ),
      CardWithTitle(
        title: "Eigenschaften",
        child: AttributeListWidget(
          held: held,
          isOneLine: true,
        ),
      ),
      CardWithTitle(
        title: 'Weitere Informationen',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BasiswerteTile(held: held),
            ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: const Text('Vor-/Nachteile'),
                children: [
                  SearchableDataTable(
                      held: held,
                      stringList: held.vorteile,
                      col1Label: 'Vorteil')
                ]),
            ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: const Text('Sonderfertigkeiten'),
                children: [
                  SearchableDataTable(
                      held: held,
                      stringList: held.sf,
                      col1Label: 'Sonderfertigkeit')
                ]),
          ],
        ),
      ),
      Card(
        child: ExpansionTileWithTitle(
          title: "Talente",
          hasTitle: true,
          child: SkillList(
              hasSliverParent: false,
              held: held,
              skillMap: held.talents,
              rollCallback: (talentName, taw, penalty) {
                String msg = getIt<RollManager>()
                    .rollTalent(held, talentName, penalty);
                if (held.owner == cu.uuid) {
                  getIt<MessageAmplifySubscriptionService>()
                      .createMessage(msg, held.gruppeId, cu.uuid);
                } else {
                  messageController.add(ChatMessage(
                      messageContent: msg,
                      groupId: held.gruppeId,
                      timestamp: DateTime.now(),
                      ownerId: cu.uuid,
                      isPrivate: true));
                }
              }),
        ),
      ),
      if(held.asp.value > 0)
        Card(
          child: ExpansionTileWithTitle(
            title: "Zauber",
            hasTitle: true,
            child: SkillList(
                hasSliverParent: false,
                held: held,
                skillMap: held.zauber,
                rollCallback: (talentName, taw, penalty) {
                  String msg = getIt<RollManager>()
                      .rollZauber(held, talentName, penalty);
                  if (held.owner == cu.uuid) {
                    getIt<MessageAmplifySubscriptionService>()
                        .createMessage(msg, held.gruppeId, cu.uuid);
                  } else {
                    messageController.add(ChatMessage(
                        messageContent: msg,
                        groupId: held.gruppeId,
                        timestamp: DateTime.now(),
                        ownerId: cu.uuid,
                        isPrivate: true));
                  }
                }),
          ),
        ),
      Card(
        child: ExpansionTileWithTitle(
          title: "Items",
          hasTitle: true,
          child: SingleChildScrollView(child: ItemList(held: held)),
        ),
      ),
    if(held.owner == cu.uuid)
      Card(
        child: NotesExpansionTile(
            controller: _controller,
            getNoteCallback: () async {
              //TODO refactor, dupe
              Note? note = await getIt<NoteAmplifyService>().getNoteForHeld(held.uuid);
              if(note == null){
                print("NOTE IS NULL");
                return;
              }
              List<dynamic> quillJson = jsonDecode(note.content);
              _controller.document = Document.fromJson(quillJson);
            },
            saveCallback: (documentString) async {
              if (held.owner != cu.uuid) {
                EasyLoading.showToast(
                    "Notizen können aktuell nur vom Spieler gespeichert werden");
                return;
              }
              //TODO refactor
              var shouldCreate = false;
              Note? note = await getIt<NoteAmplifyService>()
                  .getNoteForHeld(held.uuid);
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
                var heldSaved =
                await getIt<HeldAmplifyService>()
                    .updateHeldWithNote(
                    held.uuid, note.uuid);
                if (heldSaved) {
                  EasyLoading.showToast(
                      "Notiz wurde gespeichert: $heldSaved");
                }
              }
            }),
      )
    ];

    var size = MediaQuery.of(context).size;
    double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
    double firstRowHeight = largeCardHeight; // Adjust as needed
    double topPadding = 20; // Adjust as needed
    var itemsPerRow = 4;

    double availableHeight = size.height - (firstRowHeight + appBarHeight + topPadding);
    double availableWidth = (size.width  - (itemsPerRow - 1) * 10) / itemsPerRow;

    return Wrap(
      spacing: 10, // Horizontal space between children
      runSpacing: 10, // Vertical space between lines
      children: children
          .asMap()
          .map((index, child) {
        int rowIndex = getRowIndex(index, children.length, context, availableWidth);
        double childMaxHeight = largeCardHeight;
        if (rowIndex > 0) {
          // Calculate the maximum height for children in the second and subsequent rows
          childMaxHeight = max(availableHeight / (rowIndex), largeCardHeight);
        }
        return MapEntry(
          index,
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: availableWidth,
              maxHeight: childMaxHeight,
              minHeight: childMaxHeight,
            ),
            child: child,
          ),
        );
      }).values.toList(),
    );



  }

  int getRowIndex(int index, int itemCount, BuildContext context, double itemWidth) {
    double screenWidth = MediaQuery.of(context).size.width;
    int itemsPerRow = screenWidth ~/ itemWidth;
    int rowNumber = index ~/ itemsPerRow;
    return rowNumber;
  }

  int getMaxRows(int itemCount,int itemCount2, BuildContext context, double itemWidth){
      return 0;
  }
}
