import 'package:flutter/material.dart';

import '../../Held/Held.dart';
import '../../rules/RollCalculator.dart';
import '../../rules/RuleProvider.dart';
import '../../skills/ISkill.dart';
import '../AsyncText.dart';

class SkillChanceText extends StatelessWidget {
  final ValueNotifier<int> modificator;
  final String skillName;
  final Held held;

  const SkillChanceText({
    super.key,
    required this.modificator,
    required this.skillName,
    required this.held,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: modificator,
      builder: (context, value, child) {
        return AsyncText(
          callback: () async {
            ISkill? skill = RuleProvider.getSkillByName(skillName);
            int mod = RuleProvider.getModificator(skill, value);
            return RollCalculator.calcChance(held, skill, mod);
          },
          showSpinner: false,
        );
      },
    );
  }
}
