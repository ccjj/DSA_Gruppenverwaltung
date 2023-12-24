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
import 'HeldDetailScreen/CardWithTitle.dart';
import 'HeldDetailScreen/HeroDetailCard.dart';
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
          body: ResponsiveGridView.builder(
            itemCount: 7,
            gridDelegate: const ResponsiveGridDelegate(//SliverGridDelegateWithMaxCrossAxisExtent
              maxCrossAxisExtent: largeCardHeight, //vertical
              crossAxisExtent: 350,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              switch (index) {
                case 0:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HeroDetailCard(held: widget.held),
                  );
                case 1:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CardWithTitle(
                      title: "Vitalwerte",
                      child: Column(
                        children: [
                          PlusMinusButton(
                            title: 'Lebenspunkte (LP)',
                            enabled: widget.held.owner == cu.uuid,
                            leading:
                                const Icon(Icons.favorite, color: Colors.red),
                            value: widget.held.lp,
                            maxValue: widget.held.maxLp.value,
                            onValueChanged: (newVal) {
                              getIt<ActionStack>().handleUserAction(
                                  newVal,
                                  "lp",
                                  ActionSource.client,
                                  () => widget.held.lp.value = newVal);
                              getIt<HeldService>().updateHeldFromInput(
                                  UpdateHeldInput(
                                      id: widget.held.uuid, lp: newVal));
                            },
                          ),
                          if (widget.held.maxAsp.value > 0)
                            PlusMinusButton(
                              title: 'Astralpunkte (ASP)',
                              enabled: widget.held.owner == cu.uuid,
                              leading: const Icon(Icons.flash_on_outlined,
                                  color: Colors.lightBlueAccent),
                              value: widget.held.asp,
                              maxValue: widget.held.maxAsp.value,
                              onValueChanged: (newVal) {
                                getIt<ActionStack>().handleUserAction(
                                    newVal,
                                    "asp",
                                    ActionSource.client,
                                    () => widget.held.asp.value = newVal);
                                getIt<HeldService>().updateHeldFromInput(
                                    UpdateHeldInput(
                                        id: widget.held.uuid, asp: newVal));
                              },
                            ),
                          PlusMinusButton(
                            title: 'Ausdauer (AU)',
                            enabled: widget.held.owner == cu.uuid,
                            leading: const Icon(Icons.directions_run_outlined,
                                color: Colors.amber),
                            value: widget.held.au,
                            maxValue: widget.held.maxAu.value,
                            onValueChanged: (newVal) {
                              getIt<ActionStack>().handleUserAction(
                                  newVal,
                                  "au",
                                  ActionSource.client,
                                  () => widget.held.au.value = newVal);
                              getIt<HeldService>().updateHeldFromInput(
                                  UpdateHeldInput(
                                      id: widget.held.uuid, au: newVal));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                case 2:
                  return CardWithTitle(
                    title: "Eigenschaften",
                    child: AttributeListWidget(held: widget.held, isOneLine: true,),
                  );
                case 3:
                  return CardWithTitle(
                    title: 'Weitere Informationen',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExpansionTile(
                          iconColor: Colors.red,
                          collapsedIconColor: Colors.red,
                          title: const Text('Basiswerte'),
                          children: <Widget>[
                            ListTile(
                              title: const Text('Magieresistenz (MR)'),
                              subtitle: Text('${widget.held.mr}'),
                            ),
                            ListTile(
                              title: const Text('Initiative (INI)'),
                              subtitle: Text('${widget.held.ini} / ${widget.held.baseIni}'),
                            ),
                            ListTile(
                              title: const Text('Basisinitiative'),
                              subtitle: Text('${widget.held.baseIni}'),
                            ),
                            ListTile(
                              title: const Text('Angriffswert (AT)'),
                              subtitle: Text('${widget.held.at}'),
                            ),
                            ListTile(
                              title: const Text('Parade (PA)'),
                              subtitle: Text('${widget.held.pa}'),
                            ),
                            ListTile(
                              title: const Text('Fernkampfwert (FK)'),
                              subtitle: Text('${widget.held.fk}'),
                            ),
                            ListTile(
                              title: const Text('Wundschwelle (WS)'),
                              subtitle: Text('${widget.held.ws}'),
                            ),
                          ],
                        ),
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
                  );
                case 4:
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 8),
                              child: Text("Talente", style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize)),
                            )
                        ),
                        Expanded(
                          child: SkillList(
                            hasSliverParent: false,
                              held: widget.held,
                              skillMap: widget.held.talents,
                              rollCallback: (talentName, taw, penalty) {
                                String msg = getIt<RollManager>()
                                    .rollTalent(widget.held, talentName, penalty);
                                if (widget.held.owner == cu.uuid) {
                                  getIt<MessageAmplifyService>().createMessage(
                                      msg, widget.held.gruppeId, cu.uuid);
                                } else {
                                  messageController.add(ChatMessage(
                                      messageContent: msg,
                                      groupId: widget.held.gruppeId,
                                      timestamp: DateTime.now(),
                                      ownerId: cu.uuid,
                                      isPrivate: true));
                                }
                              }),
                        ),
                      ],
                    ),
                  );
                case 5:
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 8),
                              child: Text("Zauber", style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize)),
                            )
                        ),
                        Expanded(
                          child: SkillList(
                            hasSliverParent: false,
                              held: widget.held,
                              skillMap: widget.held.zauber,
                              rollCallback: (talentName, taw, penalty) {
                                String msg = getIt<RollManager>()
                                    .rollZauber(widget.held, talentName, penalty);
                                if (widget.held.owner == cu.uuid) {
                                  getIt<MessageAmplifyService>().createMessage(
                                      msg, widget.held.gruppeId, cu.uuid);
                                } else {
                                  messageController.add(ChatMessage(
                                      messageContent: msg,
                                      groupId: widget.held.gruppeId,
                                      timestamp: DateTime.now(),
                                      ownerId: cu.uuid,
                                      isPrivate: true));
                                }
                              }),
                        ),
                      ],
                    ),
                  );
                case 6:
                  return CardWithTitle(
                      title: "Items",
                      child: ItemList(held: widget.held));
                default:
                  return Text("dd");
              }
            },
          ));
    }
    return MainScaffold(
      title: const Text(pageTitle),
      bnb: ChatBottomBar(
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
                        child: Column(
                          children: [
                            PlusMinusButton(
                              title: 'Lebenspunkte (LP)',
                              enabled: widget.held.owner == cu.uuid,
                              leading:
                                  const Icon(Icons.favorite, color: Colors.red),
                              value: widget.held.lp,
                              maxValue: widget.held.maxLp.value,
                              onValueChanged: (newVal) {
                                getIt<ActionStack>().handleUserAction(
                                    newVal,
                                    "lp",
                                    ActionSource.client,
                                    () => widget.held.lp.value = newVal);
                                getIt<HeldService>().updateHeldFromInput(
                                    UpdateHeldInput(
                                        id: widget.held.uuid, lp: newVal));
                              },
                            ),
                            if (widget.held.maxAsp.value > 0)
                              PlusMinusButton(
                                title: 'Astralpunkte (ASP)',
                                enabled: widget.held.owner == cu.uuid,
                                leading: const Icon(Icons.flash_on_outlined,
                                    color: Colors.lightBlueAccent),
                                value: widget.held.asp,
                                maxValue: widget.held.maxAsp.value,
                                onValueChanged: (newVal) {
                                  getIt<ActionStack>().handleUserAction(
                                      newVal,
                                      "asp",
                                      ActionSource.client,
                                      () => widget.held.asp.value = newVal);
                                  getIt<HeldService>().updateHeldFromInput(
                                      UpdateHeldInput(
                                          id: widget.held.uuid, asp: newVal));
                                },
                              ),
                            PlusMinusButton(
                              title: 'Ausdauer (AU)',
                              enabled: widget.held.owner == cu.uuid,
                              leading: const Icon(Icons.directions_run_outlined,
                                  color: Colors.amber),
                              value: widget.held.au,
                              maxValue: widget.held.maxAu.value,
                              onValueChanged: (newVal) {
                                getIt<ActionStack>().handleUserAction(
                                    newVal,
                                    "au",
                                    ActionSource.client,
                                    () => widget.held.au.value = newVal);
                                getIt<HeldService>().updateHeldFromInput(
                                    UpdateHeldInput(
                                        id: widget.held.uuid, au: newVal));
                              },
                            ),
                          ],
                        ),
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
            child: ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              title: const Text('Basiswerte'),
              children: <Widget>[
                ListTile(
                  title: const Text('Magieresistenz (MR)'),
                  subtitle: Text('${widget.held.mr}'),
                ),
                ListTile(
                  title: const Text('Initiative (INI)'),
                  subtitle: Text('${widget.held.ini} / ${widget.held.baseIni}'),
                ),
                ListTile(
                  title: const Text('Basisinitiative'),
                  subtitle: Text('${widget.held.baseIni}'),
                ),
                ListTile(
                  title: const Text('Angriffswert (AT)'),
                  subtitle: Text('${widget.held.at}'),
                ),
                ListTile(
                  title: const Text('Parade (PA)'),
                  subtitle: Text('${widget.held.pa}'),
                ),
                ListTile(
                  title: const Text('Fernkampfwert (FK)'),
                  subtitle: Text('${widget.held.fk}'),
                ),
                ListTile(
                  title: const Text('Wundschwelle (WS)'),
                  subtitle: Text('${widget.held.ws}'),
                ),
              ],
            ),
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
