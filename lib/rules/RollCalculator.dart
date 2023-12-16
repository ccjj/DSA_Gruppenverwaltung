import 'dart:math';

import '../Held/Held.dart';
import '../skills/ISkill.dart';
import '../skills/Talent.dart';
import '../skills/Zauber.dart';
import 'RuleProvider.dart';

class RollCalculator {
  static Future<double> _calculateTalentProbeChance(int e1, int e2, int e3, int taw, int mod) async {
    var erfolge = 0;
    for (var x = 1; x < 21; x++) {
      for (var y = 1; y < 21; y++) {
        for (var z = 1; z < 21; z++) {
          var erfolg = false;
          if ((x == 1 && (y == 1 || z == 1)) || (y == 1 && z == 1)) erfolg = true;
          else if ((x == 20 && (y == 20 || z == 20)) || (y == 20 && z == 20)) erfolg = false;
          else {
            var p = taw - mod;
            if (p < 1) {
              erfolg = (x <= e1 + p && y <= e2 + p && z <= e3 + p);
            } else {
              if (x > e1) p -= (x - e1);
              if (y > e2) p -= (y - e2);
              if (z > e3) p -= (z - e3);
              erfolg = (p > -1);
            }
          }
          if (erfolg) erfolge++;
        }
      }
    }
    return erfolge / 8000.0;
  }

  static double _calculateSingleTalentProbeChance(int taw, int mod) {
    int effectiveTAW = taw - mod;
    if (effectiveTAW <= 0) {
      return 0.0;
    }

    int successCases = 0;
    for (int roll = 1; roll <= 20; roll++) {
      if (roll <= effectiveTAW || roll == 1) {
        successCases++;
      } else if (roll == 20) {
        successCases--;
      }
    }

    return successCases / 20.0;
  }


  static Future<String> calcChance(Held held, ISkill? skill, int? tpenalty) async {
    var penalty = tpenalty ?? 0;
    if(skill == null){
      return "";
    }
    int? taw = RuleProvider.getTaw(held, skill);
    if(taw == null){
      return "";
    }
    if(skill.wurf == null || skill.wurf! == ""){
      //TODO
      return "";
      var calculatedChance = _calculateSingleTalentProbeChance(taw, penalty * -1);
      return "${(calculatedChance * 100).toStringAsFixed(0).replaceFirst(".", ",")}%";
    }
    var propsToRoll = RuleProvider.getPropsToRoll(skill).toList();
    if(propsToRoll.length != 3){
      return "";
    }
    var attributes = [];

    propsToRoll.forEach((attributePropStr) {
      int attr = held.getAttribute(attributePropStr.toLowerCase())!;
      attributes.add(attr);
    });
    var calculatedChance = await _calculateTalentProbeChance(attributes[0], attributes[1], attributes[2], taw, penalty * -1);
    return "${(calculatedChance * 100).toStringAsFixed(0).replaceFirst(".", ",")}%";
  }

}
