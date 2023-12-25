import 'package:flutter/material.dart';

import '../Held/Held.dart';
import '../Held/HeldService.dart';
import '../Held/UpdateHeldInput.dart';
import '../actions/ActionSource.dart';
import '../actions/ActionStack.dart';
import '../globals.dart';
import '../widgets/PlusMinusButton.dart';

class VitalWerteColumn extends StatelessWidget {
  final Held held;

  const VitalWerteColumn({
    super.key,
    required this.held,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlusMinusButton(
          title: 'Lebenspunkte (LP)',
          enabled: held.owner == cu.uuid,
          leading: const Icon(Icons.favorite, color: Colors.red),
          value: held.lp,
          maxValue: held.maxLp.value,
          onValueChanged: (newVal) {
            getIt<ActionStack>().handleUserAction(
                newVal,
                "lp",
                ActionSource.client,
                    () => held.lp.value = newVal);
            getIt<HeldService>().updateHeldFromInput(
                UpdateHeldInput(id: held.uuid, lp: newVal));
          },
        ),
        if (held.maxAsp.value > 0)
          PlusMinusButton(
            title: 'Astralpunkte (ASP)',
            enabled: held.owner == cu.uuid,
            leading: const Icon(Icons.flash_on_outlined,
                color: Colors.lightBlueAccent),
            value: held.asp,
            maxValue: held.maxAsp.value,
            onValueChanged: (newVal) {
              getIt<ActionStack>().handleUserAction(
                  newVal,
                  "asp",
                  ActionSource.client,
                      () => held.asp.value = newVal);
              getIt<HeldService>().updateHeldFromInput(
                  UpdateHeldInput(
                      id: held.uuid, asp: newVal));
            },
          ),
        PlusMinusButton(
          title: 'Ausdauer (AU)',
          enabled: held.owner == cu.uuid,
          leading: const Icon(Icons.directions_run_outlined,
              color: Colors.amber),
          value: held.au,
          maxValue: held.maxAu.value,
          onValueChanged: (newVal) {
            getIt<ActionStack>().handleUserAction(
                newVal,
                "au",
                ActionSource.client,
                    () => held.au.value = newVal);
            getIt<HeldService>().updateHeldFromInput(
                UpdateHeldInput(id: held.uuid, au: newVal));
          },
        ),
      ],
    );
  }
}
