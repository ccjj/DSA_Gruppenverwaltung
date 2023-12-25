import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/chat/MessageAmplifyService.dart';
import 'package:dsagruppen/rules/RollManager.dart';
import 'package:dsagruppen/widgets/AnimatedIconButton.dart';
import 'package:dsagruppen/widgets/ConditionalParentWidget.dart';
import 'package:dsagruppen/widgets/PlusMinusButton.dart';
import 'package:dsagruppen/widgets/SearchableDataTable.dart';
import 'package:dsagruppen/widgets/experimental/ItemList.dart';
import 'package:dsagruppen/widgets/experimental/SkillList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:responsive_framework/responsive_grid.dart';

import 'Held/Held.dart';
import 'Held/UpdateHeldInput.dart';
import 'HeldDetailScreen/AttributeListWidget.dart';
import 'HeldDetailScreen/BasisWerteTile.dart';
import 'HeldDetailScreen/CardWithTitle.dart';
import 'HeldDetailScreen/HeroDetailCard.dart';
import 'HeldDetailScreen/VitalWerteColumn.dart';
import 'actions/ActionSource.dart';
import 'actions/ActionStack.dart';
import 'chat/ChatBottomBar.dart';
import 'chat/ChatOverlay.dart';
import 'globals.dart';
import 'widgets/MainScaffold.dart';

class HeldDetailsScreen extends StatefulWidget {
  final Held held;

  const HeldDetailsScreen({super.key, required this.held});

  @override
  State<HeldDetailsScreen> createState() => _HeldDetailsScreenState();
}

class _HeldDetailsScreenState extends State<HeldDetailsScreen> {
  final flipController = FlipCardController();
  var isTalentsExpanded = ValueNotifier(false);
  var isZauberExpanded = ValueNotifier(false);
  ExpansionTileController talentExpansionController = ExpansionTileController();
  ExpansionTileController zauberExpansionController = ExpansionTileController();
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
          body: DesktopView(largeCardHeight: largeCardHeight, widget: widget));
    }
    return MainScaffold(
      title: const Text(pageTitle),
      bnb: (ResponsiveBreakpoints.of(context).largerThan(TABLET)) ? null : ChatBottomBar(
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
            child:BasiswerteTile(held: widget.held),
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
                    getIt<MessageAmplifyService>()
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
                    getIt<MessageAmplifyService>()
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
  const DesktopView({
    super.key,
    required this.largeCardHeight,
    required this.widget,
  });

  final double largeCardHeight;
  final HeldDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: HeroDetailCard(held: widget.held),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CardWithTitle(
          title: "Vitalwerte",
          child: VitalWerteColumn(held: widget.held),
        ),
      ),
      CardWithTitle(
        title: "Eigenschaften",
        child: AttributeListWidget(
          held: widget.held,
          isOneLine: true,
        ),
      ),
      CardWithTitle(
        title: 'Weitere Informationen',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BasiswerteTile(held: widget.held),
            ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: const Text('Vor-/Nachteile'),
                children: [
                  SearchableDataTable(
                      held: widget.held,
                      stringList: widget.held.vorteile,
                      col1Label: 'Vorteil')
                ]),
            ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: const Text('Sonderfertigkeiten'),
                children: [
                  SearchableDataTable(
                      held: widget.held,
                      stringList: widget.held.sf,
                      col1Label: 'Sonderfertigkeit')
                ]),
          ],
        ),
      ),
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Text("Talente",
                      style: TextStyle(
                          fontSize: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .fontSize)),
                )),
            Expanded(
              child: SkillList(
                  hasSliverParent: false,
                  held: widget.held,
                  skillMap: widget.held.talents,
                  rollCallback: (talentName, taw, penalty) {
                    // Your rollCallback implementation
                  }),
            ),
          ],
        ),
      ),
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Text("Zauber",
                      style: TextStyle(
                          fontSize: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .fontSize)),
                )),
            Expanded(
              child: SkillList(
                  hasSliverParent: false,
                  held: widget.held,
                  skillMap: widget.held.zauber,
                  rollCallback: (talentName, taw, penalty) {
                    // Your rollCallback implementation
                  }),
            ),
          ],
        ),
      ),
      CardWithTitle(
        title: "Items",
        child: ItemList(held: widget.held),
      ),
      // Add any additional children here
    ];

    //400x350

    return SingleChildScrollView(
      child: Wrap(
        spacing: 10, // Horizontal space between children
        runSpacing: 10, // Vertical space between lines
        children: children.map((child) => ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350, maxHeight: largeCardHeight, minHeight: largeCardHeight), // Max width for each child
          child: child,
        )).toList(),
      ),
    );
  }
}
