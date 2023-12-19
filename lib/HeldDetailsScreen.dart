import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/HeldDetailScreen/showCurrencyConverterDialog.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/chat/MessageAmplifyService.dart';
import 'package:dsagruppen/rules/RollManager.dart';
import 'package:dsagruppen/services/MoneyConversion.dart';
import 'package:dsagruppen/widgets/AsyncText.dart';
import 'package:dsagruppen/widgets/PlusMinusButton.dart';
import 'package:dsagruppen/widgets/SearchableDataTable.dart';
import 'package:dsagruppen/widgets/experimental/ItemList.dart';
import 'package:dsagruppen/widgets/experimental/SkillList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';

import 'Held/Held.dart';
import 'Held/UpdateHeldInput.dart';
import 'User/UserAmplifyService.dart';
import 'actions/ActionSource.dart';
import 'actions/ActionStack.dart';
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

  @override
  void initState() {
    super.initState();
    getIt<ChatOverlay>().gruppeId = widget.held.gruppeId;
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: const Text("Heldendetails"),
      body: CustomScrollView(
        slivers: [
          if (isTest)
            SliverToBoxAdapter(
              child: TextButton(
                  onPressed: () {
                    isChatVisible.value = !isChatVisible.value;
                  },
                  child: const Text("show chat")),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // Assuming you have two main widgets to display
                switch (index) {
                  case 0:
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => flipController.flipcard(),
                        child: FlipCard(
                          animationDuration: const Duration(milliseconds: 300),
                          controller: flipController,
                          frontWidget: Card(
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.only(left: 16),
                                  leading: const Icon(
                                      Icons.badge_outlined), // Icon für 'Name'
                                  title: Text(widget.held.name),
                                  trailing: IconButton(
                                      icon: const Icon(Icons.info_outline_rounded),
                                      onPressed: () =>
                                          //_showHeldInfoDialog(context, widget.held),
                                          flipController.flipcard()),
                                ),
                                ListTile(
                                  leading: const Icon(Icons
                                      .school_outlined), // Icon für 'Ausbildung'
                                  title: Text('${widget.held.ausbildung}'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.savings_outlined),
                                  title: ValueListenableBuilder(
                                      valueListenable: widget.held.kreuzer,
                                      builder: (context, value, child) {
                                        return Text(
                                            MoneyConversion.toDSACurrency(
                                                widget.held.kreuzer.value));
                                      }),
                                  trailing: widget.held.owner == cu.uuid
                                      ? const Icon(Icons.edit)
                                      : null,
                                  //TODO update held
                                  onTap: widget.held.owner == cu.uuid
                                      ? () {
                                          showCurrencyConverterDialog(
                                              context, widget.held,
                                              (int newKreuzer) {
                                            if (widget.held.kreuzer.value !=
                                                newKreuzer) {
                                              widget.held.kreuzer.value =
                                                  newKreuzer;
                                            }
                                            getIt<ActionStack>()
                                                .handleUserAction(
                                                    newKreuzer,
                                                    "kreuzer",
                                                    ActionSource.client,
                                                    () => widget.held.kreuzer
                                                        .value = newKreuzer);
                                            getIt<HeldService>()
                                                .updateHeldFromInput(
                                                    UpdateHeldInput(
                                                        id: widget.held.uuid,
                                                        kreuzer: newKreuzer));
                                            return 0;
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          backWidget: Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons
                                      .accessibility_new), // Icon für 'Rasse'
                                  title: Text(widget.held.rasse),
                                  contentPadding: const EdgeInsets.only(left: 16),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.info_outline_rounded),
                                    onPressed: () =>
                                        //_showHeldInfoDialog(context, widget.held),
                                        flipController.flipcard(),
                                  ),
                                ),
                                ListTile(
                                  leading:
                                      const Icon(Icons.public), // Icon für 'Kultur'
                                  title: Text(widget.held.kultur),
                                ),
                                ListTile(
                                  leading: const Icon(Icons
                                      .star_border), // Icon für 'Abenteuerpunkte (AP)'
                                  title: Text(' ${widget.held.ap} AP'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons
                                      .account_circle), // Icon für 'Benutzer'
                                  title: AsyncText(
                                    prefixText: "Account ",
                                    callback: () async {
                                      var foundUser =
                                          await getIt<UserAmplifyService>()
                                              .getUser(widget.held.owner);
                                      if (foundUser == null) {
                                        return "?";
                                      }
                                      return foundUser!.name;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          rotateSide: RotateSide.right,
                          axis: FlipAxis.vertical,
                        ),
                      ),
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
                              leading: const Icon(Icons.favorite, color: Colors.red),
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
              childCount:
                  2, // Set the count based on the number of items you have
            ),
          ),
          SliverToBoxAdapter(
            child: ExpansionTile(
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              title: const Text('Eigenschaften'),
              children: [
                ListTile(
                  title: const Text('Mut (MU)'),
                  subtitle: Text('${widget.held.mu}'),
                ),
                ListTile(
                  title: const Text('Klugheit (KL)'),
                  subtitle: Text('${widget.held.kl}'),
                ),
                ListTile(
                  title: const Text('Intuition (IN)'),
                  subtitle: Text('${widget.held.intu}'),
                ),
                ListTile(
                  title: const Text('Charisma (CH)'),
                  subtitle: Text('${widget.held.ch}'),
                ),
                ListTile(
                  title: const Text('Fingerfertigkeit (FF)'),
                  subtitle: Text('${widget.held.ff}'),
                ),
                ListTile(
                  title: const Text('Gewandtheit (GE)'),
                  subtitle: Text('${widget.held.ge}'),
                ),
                ListTile(
                  title: const Text('Konstitution (KO)'),
                  subtitle: Text('${widget.held.ko}'),
                ),
                ListTile(
                  title: const Text('Körperkraft (KK)'),
                  subtitle: Text('${widget.held.kk}'),
                ),
                ListTile(
                  title: const Text('Sozialstatus (SO)'),
                  subtitle: Text('${widget.held.so}'),
                ),
                ListTile(
                  title: const Text('Geschwindigkeit (GS)'),
                  subtitle: Text('${widget.held.gs}'),
                ),
              ],
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
                  title: const Text('Fernkampfwert (FK)'), //TODO
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
          if(isTalentsExpanded.value)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor), // Only top border
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
                children: const [
                ],
                onExpansionChanged: (bool expanded) {
                  isTalentsExpanded.value = !isTalentsExpanded.value;
                  setState(() {});
                },
              ),
            ),
          ),
          if (isTalentsExpanded.value)
            SkillList(
                held: widget.held,
                skillMap: widget.held.talents,
                rollCallback: (talentName, penalty) {
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
          if(isTalentsExpanded.value)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor), // Only top border
                  ),
                ),
              ),
            ),
          if(isZauberExpanded.value)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor), // Only top border
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
                children: const [
                ],
                onExpansionChanged: (bool expanded) {
                  isZauberExpanded.value = !isZauberExpanded.value;
                  setState(() {});
                },
              ),
            ),
          ),
          if (isZauberExpanded.value)
            SkillList(
                held: widget.held,
                skillMap: widget.held.zauber,
                rollCallback: (talentName, penalty) {
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
          if(isZauberExpanded.value)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor), // Only top border
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

  String talentsToString(Map<String, int> talents) {
    return talents.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  String itemsToString(Map<String, int> items) {
    return items.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

}
