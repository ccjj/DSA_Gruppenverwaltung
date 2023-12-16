import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/chat/ChatMessage.dart';
import 'package:dsagruppen/chat/MessageAmplifyService.dart';
import 'package:dsagruppen/extensions/IterableExtensions.dart';
import 'package:dsagruppen/rules/RollManager.dart';
import 'package:dsagruppen/services/MoneyConversion.dart';
import 'package:dsagruppen/skills/TalentRepository%20.dart';
import 'package:dsagruppen/widgets/AsyncText.dart';
import 'package:dsagruppen/HeldDetailScreen/CurrencyConverter.dart';
import 'package:dsagruppen/widgets/experimental/ItemList.dart';
import 'package:dsagruppen/widgets/PlusMinusButton.dart';
import 'package:dsagruppen/widgets/SearchableDataTable.dart';
import 'package:dsagruppen/HeldDetailScreen/showCurrencyConverterDialog.dart';
import 'package:dsagruppen/widgets/experimental/SkillList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';

import 'Held/Held.dart';
import 'Held/UpdateHeldInput.dart';
import 'chat/ChatOverlay.dart';
import 'widgets/MainScaffold.dart';
import 'User/UserAmplifyService.dart';
import 'actions/ActionSource.dart';
import 'actions/ActionStack.dart';
import 'globals.dart';

class HeldDetailsScreen extends StatefulWidget {
  final Held held;

  const HeldDetailsScreen({super.key, required this.held});

  @override
  State<HeldDetailsScreen> createState() => _HeldDetailsScreenState();
}

class _HeldDetailsScreenState extends State<HeldDetailsScreen> {
  final flipController = FlipCardController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    getIt<ChatOverlay>().gruppeId = widget.held.gruppeId;
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: Text("Heldendetails"),
      body: CustomScrollView(
        slivers:
           [
            if(isTest) SliverToBoxAdapter(
              child: TextButton(onPressed: (){
                isChatVisible.value = !isChatVisible.value;
              }, child: Text("show chat")),
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
                                     contentPadding: EdgeInsets.only(left: 16),
                                     leading:
                                     Icon(Icons.badge_outlined), // Icon für 'Name'
                                     title: Text(widget.held.name),
                                     trailing: IconButton(
                                         icon: Icon(Icons.info_outline_rounded),
                                         onPressed: () =>
                                         //_showHeldInfoDialog(context, widget.held),
                                         flipController.flipcard()),
                                   ),
                                   ListTile(
                                     leading: Icon(Icons
                                         .school_outlined), // Icon für 'Ausbildung'
                                     title: Text('${widget.held.ausbildung}'),
                                   ),
                                   ListTile(
                                     leading: Icon(Icons.savings_outlined),
                                     title: ValueListenableBuilder(
                                         valueListenable: widget.held.kreuzer,
                                         builder: (context, value, child) {
                                           return Text(MoneyConversion.toDSACurrency(
                                               widget.held.kreuzer.value));
                                         }
                                     ),
                                     trailing: widget.held.owner == cu.uuid
                                         ? Icon(Icons.edit)
                                         : null,
                                     //TODO update held
                                     onTap: widget.held.owner == cu.uuid
                                         ? () {
                                       var oldKreuzer = widget.held.kreuzer.value;
                                       showCurrencyConverterDialog(
                                           context,
                                           widget.held,
                                               (int newKreuzer) {
                                             if(widget.held.kreuzer.value != newKreuzer){
                                               widget.held.kreuzer.value = newKreuzer;
                                             }
                                             getIt<ActionStack>().handleUserAction(
                                                 newKreuzer,
                                                 "kreuzer",
                                                 ActionSource.client,
                                                     () => widget.held.kreuzer.value = newKreuzer);
                                             getIt<HeldService>().updateHeldFromInput(
                                                 UpdateHeldInput(
                                                     id: widget.held.uuid, kreuzer: newKreuzer));
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
                                     leading: Icon(
                                         Icons.accessibility_new), // Icon für 'Rasse'
                                     title: Text(widget.held.rasse),
                                     contentPadding: EdgeInsets.only(left: 16),
                                     trailing: IconButton(
                                       icon: Icon(Icons.info_outline_rounded),
                                       onPressed: () =>
                                       //_showHeldInfoDialog(context, widget.held),
                                       flipController.flipcard(),
                                     ),
                                   ),
                                   ListTile(
                                     leading: Icon(Icons.public), // Icon für 'Kultur'
                                     title: Text(widget.held.kultur),
                                   ),
                                   ListTile(
                                     leading: Icon(Icons
                                         .star_border), // Icon für 'Abenteuerpunkte (AP)'
                                     title: Text(' ${widget.held.ap} AP'),
                                   ),
                                   ListTile(
                                     leading: Icon(
                                         Icons.account_circle), // Icon für 'Benutzer'
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
                       return  Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Card(
                           child: Column(
                             children: [
                               PlusMinusButton(
                                 title: 'Lebenspunkte (LP)',
                                 enabled: widget.held.owner == cu.uuid,
                                 leading: Icon(Icons.favorite, color: Colors.red),
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
                                   leading: Icon(Icons.flash_on_outlined,
                                       color: Colors.lightBlueAccent),
                                   value: widget.held.asp,
                                   maxValue: widget.held.maxAsp.value,
                                   onValueChanged: (newVal) {
                                     //TODO update this from input aswell
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
                                 leading: Icon(Icons.directions_run_outlined,
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
                 childCount: 2, // Set the count based on the number of items you have
               ),
             ),
             SliverToBoxAdapter(
              child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: Text('Eigenschaften'),
                children: [
                  ListTile(
                    title: Text('Mut (MU)'),
                    subtitle: Text('${widget.held.mu}'),
                  ),
                  ListTile(
                    title: Text('Klugheit (KL)'),
                    subtitle: Text('${widget.held.kl}'),
                  ),
                  ListTile(
                    title: Text('Intuition (IN)'),
                    subtitle: Text('${widget.held.intu}'),
                  ),
                  ListTile(
                    title: Text('Charisma (CH)'),
                    subtitle: Text('${widget.held.ch}'),
                  ),
                  ListTile(
                    title: Text('Fingerfertigkeit (FF)'),
                    subtitle: Text('${widget.held.ff}'),
                  ),
                  ListTile(
                    title: Text('Gewandtheit (GE)'),
                    subtitle: Text('${widget.held.ge}'),
                  ),
                  ListTile(
                    title: Text('Konstitution (KO)'),
                    subtitle: Text('${widget.held.ko}'),
                  ),
                  ListTile(
                    title: Text('Körperkraft (KK)'),
                    subtitle: Text('${widget.held.kk}'),
                  ),
                  ListTile(
                    title: Text('Sozialstatus (SO)'),
                    subtitle: Text('${widget.held.so}'),
                  ),
                  ListTile(
                    title: Text('Geschwindigkeit (GS)'),
                    subtitle: Text('${widget.held.gs}'),
                  ),
                ],
              ),
            ),
             SliverToBoxAdapter(
              child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: Text('Basiswerte'),
                children: <Widget>[
                  ListTile(
                    title: Text('Magieresistenz (MR)'),
                    subtitle: Text('${widget.held.mr}'),
                  ),
                  ListTile(
                    title: Text('Initiative (INI)'),
                    subtitle: Text('${widget.held.ini} / ${widget.held.baseIni}'),
                  ),
                  ListTile(
                    title: Text('Basisinitiative'),
                    subtitle: Text('${widget.held.baseIni}'),
                  ),
                  ListTile(
                    title: Text('Angriffswert (AT)'),
                    subtitle: Text('${widget.held.at}'),
                  ),
                  ListTile(
                    title: Text('Parade (PA)'),
                    subtitle: Text('${widget.held.pa}'),
                  ),
                  ListTile(
                    title: Text('Fernkampfwert (FK)'), //TODO
                    subtitle: Text('${widget.held.fk}'),
                  ),
                  ListTile(
                    title: Text('Wundschwelle (WS)'),
                    subtitle: Text('${widget.held.ws}'),
                  ),
                ],
              ),
            ),
             SliverToBoxAdapter(
              child: ExpansionTile(
                  iconColor: Colors.red,
                  collapsedIconColor: Colors.red,
                  title: Text('Vor-/Nachteile'),
                  children: [
                    SearchableDataTable(
                        held: widget.held,
                        stringList: widget.held.vorteile, col1Label: 'Vorteil')
                  ]),
            ),
             SliverToBoxAdapter(
              child: ExpansionTile(
                  iconColor: Colors.red,
                  collapsedIconColor: Colors.red,
                  title: Text('Sonderfertigkeiten'),
                  children: [
                    SearchableDataTable(
                        held: widget.held,
                        stringList: widget.held.sf, col1Label: 'Sonderfertigkeit')
                  ]),
            ),
             SliverToBoxAdapter(
              child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: Text('Talente'),
                children: [
                  SearchableDataTable(
                      held: widget.held,
                      stringMap: widget.held.talents,
                      col1Label: 'Talent',
                      col2Label: 'Stufe', rollCallback: (talentName, penalty) {
                        String msg = getIt<RollManager>().rollTalent(widget.held, talentName, penalty);
                        if(widget.held.owner == cu.uuid){
                          print("ISOWNER!");
                          getIt<MessageAmplifyService>().createMessage(msg, widget.held.gruppeId, cu.uuid);
                        } else {
                          messageController.add(ChatMessage(messageContent: msg, groupId: widget.held.gruppeId, timestamp: DateTime.now(), ownerId: cu.uuid, isPrivate: true));
                        }

                        //messageController.add(jsonDecode(content));
                      }
                  )
                ],
              ),
            ),
             SliverToBoxAdapter(
               child: ExpansionTile(
                 iconColor: Colors.red,
                 collapsedIconColor: Colors.red,
                 title: Text('Talente Test'),
                 children: [
                   // Minimal content or a placeholder
                 ],
                 onExpansionChanged: (bool expanded) {
                   isExpanded = !isExpanded;
                   setState(() {
                   });
                 },
               ),
             ),
             if(isExpanded)
             SkillList(held: widget.held, skillMap: widget.held.talents,rollCallback: (talentName, penalty) {
               String msg = getIt<RollManager>().rollTalent(widget.held, talentName, penalty);
               if(widget.held.owner == cu.uuid){
                 getIt<MessageAmplifyService>().createMessage(msg, widget.held.gruppeId, cu.uuid);
               } else {
                 messageController.add(ChatMessage(messageContent: msg, groupId: widget.held.gruppeId, timestamp: DateTime.now(), ownerId: cu.uuid, isPrivate: true));
               }
             }
             ),
            SliverToBoxAdapter(
              child: Visibility(
                visible: widget.held.zauber.isNotEmpty,
                child: ExpansionTile(
                  iconColor: Colors.red,
                  collapsedIconColor: Colors.red,
                  title: Text('Zauber'),
                  children: [
                    SearchableDataTable(
                        held: widget.held,
                        stringMap: widget.held.zauber,
                        col1Label: 'Zauber',
                        col2Label: 'Stufe', rollCallback: (zauberName, penalty) =>
                  getIt<RollManager>().rollZauber(widget.held, zauberName, penalty))
                  ],
                ),
              ),
            ),
             /*
             SliverToBoxAdapter(
              child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: Text('Items'),
                children: [
                  SearchableDataTable(
                      held: widget.held,
                      stringMap: widget.held.items,
                      col1Label: 'Item',
                      col2Label: 'Anzahl',
                      isEditable: true)
                ],
              ),
            ),
              */
             SliverToBoxAdapter(
              child: ExpansionTile(
                iconColor: Colors.red,
                collapsedIconColor: Colors.red,
                title: Text('Items'),
                children: [
                  ItemList(held: widget.held)
                ],
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
