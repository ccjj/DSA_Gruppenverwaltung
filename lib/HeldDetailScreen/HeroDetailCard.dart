import 'package:dsagruppen/HeldDetailScreen/showCurrencyConverterDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:flutter_flip_card/flipcard/flip_card.dart';
import 'package:flutter_flip_card/modal/flip_side.dart';

import '../Held/Held.dart';
import '../Held/HeldService.dart';
import '../Held/UpdateHeldInput.dart';
import '../User/UserAmplifyService.dart';
import '../actions/ActionSource.dart';
import '../actions/ActionStack.dart';
import '../globals.dart';
import '../services/MoneyConversion.dart';
import '../widgets/AsyncText.dart';

class HeroDetailCard extends StatefulWidget {
  final Held held;

  const HeroDetailCard({super.key, required this.held});

  @override
  State<HeroDetailCard> createState() => _HeroDetailCardState();
}

class _HeroDetailCardState extends State<HeroDetailCard> {
  final FlipCardController flipController = FlipCardController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => flipController.flipcard(),
      child: FlipCard(
        animationDuration: const Duration(milliseconds: 300),
        controller: flipController,
        frontWidget: Card(
          child: Column(
            children: [
              ListTile(
                contentPadding:
                const EdgeInsets.only(left: 16),
                leading: const Icon(
                    Icons.badge_outlined), // Icon für 'Name'
                title: Text(widget.held.name),
                trailing: IconButton(
                    icon: const Icon(
                        Icons.info_outline_rounded),
                    onPressed: () =>
                    flipController.flipcard()),
              ),
              ListTile(
                leading: const Icon(Icons
                    .school_outlined), // Icon für 'Ausbildung'
                title: Text(widget.held.ausbildung),
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
                contentPadding:
                const EdgeInsets.only(left: 16),
                trailing: IconButton(
                  icon:
                  const Icon(Icons.info_outline_rounded),
                  onPressed: () =>
                  //_showHeldInfoDialog(context, held),
                  flipController.flipcard(),
                ),
              ),
              ListTile(
                leading: const Icon(
                    Icons.public), // Icon für 'Kultur'
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
                    return foundUser.name;
                  },
                ),
              ),
            ],
          ),
        ),
        rotateSide: RotateSide.right,
        axis: FlipAxis.vertical,
      ),
    );
  }
}
