import 'dart:math';

import 'package:dsagruppen/skills/ISkill.dart';
import 'package:dsagruppen/skills/Zauber.dart';

import '../Held/Held.dart';
import '../globals.dart';
import '../skills/Talent.dart';
import '../skills/TalentRepository .dart';
import '../skills/ZauberRepository.dart';
import 'RuleProvider.dart';

class RollManager {
  Random _random = Random();

  //todo mali wie
  String roll(Held held, ISkill skill, int penalty) {
    int? taw = RuleProvider.getTaw(held, skill);

    var propsToRoll = RuleProvider.getPropsToRoll(skill);
    final bf = StringBuffer();

    if (taw == null) {
      print(held.talents);
      return "Fehler: Talent/Zauber ${skill.name} not found";
    }
    if (propsToRoll.length != 3) {
      //TODO oder auch auf attr würfe erlauben?
      //dann eigene func
      //failed, todo
      print(
          "nicht drei attribute zum würfeln angegeben. einzelwürfel wird benutzt");
      var roll = _random.nextInt(20) + 1;
      if (taw < roll) {
        print("nicht geschafft");
      } else {
        print("geschafft");
      }
      return ("TAW ${taw}, gerollt $roll");
      //TODO wurf auf talent oder attr
    }
    print(propsToRoll);
//TODO attributo

    bool firstLine = true;
    bf.write("${held.name} würfelt ");
    if (penalty == 0) {
      bf.write("(nicht erschwert) ");
    }
    if (penalty < 0) {
      bf.write("(erschwert um ${penalty * -1}) ");
    }
    if (penalty > 0) {
      bf.write("(erleichtert um $penalty) ");
    }
    bf.write("auf ${skill.name}, ");

    //int skillLeft = skill;
    propsToRoll.forEach((attributePropStr) {
      int attr = held.getAttribute(attributePropStr.toLowerCase())!;
      print(attr);
      //sprachen//lesen selbe problen, sprachen klinch, lesen klklff
      //TODO talent höhe übergeben?
      var roll = _random.nextInt(20) + 1;
      print(roll.toString());
      if (!firstLine) {
        bf.write(', ');
      }
      bf.write(roll.toString());
      firstLine = false;
      if (attr < roll) {
        taw = taw! - (roll - attr);
      }
    });
    int result = taw! - (penalty * -1) > taw! ? taw! : taw! - (penalty * -1);
    bf.write(". Resultat: ${result}");
    print("TAW: $taw");
    return bf.toString();
  }

  String rollTalent(Held held, String talentName, int penalty) {
    Talent? talent = getIt<TalentRepository>().get(talentName);
    if (talentName.toLowerCase().startsWith("sprachen")) {
      talent = Talent(name: talentName, typ: 'SPRACHEN', wurf: 'KL/IN/CH');
    }
    if (talentName.toLowerCase().startsWith("lesen")) {
      talent = Talent(name: talentName, typ: 'SPRACHEN', wurf: 'KL/KL/FF');
    }
    if (talent == null) {
      return ("Fehler: Talent $talentName nicht gefunden");
    }
    return getIt<RollManager>().roll(held, talent, penalty);
  }

  String rollZauber(Held held, String zauberName, int penalty) {
    Zauber? zauber = getIt<ZauberRepository>().get(zauberName);
    if (zauber == null) {
      print("zauber $zauberName not found");
      return "Zauber nicht gefunden";
    }
    return getIt<RollManager>().roll(held, zauber, penalty);
  }

  String rollSingleTest(
      String heldName, String skillName, int taw, int penalty) {
    final bf = StringBuffer();
    bf.write("${heldName} würfelt ");
    if (penalty == 0) {
      bf.write("(nicht erschwert) ");
    }
    else if (penalty < 0) {
      bf.write("(erschwert um ${penalty * -1}) ");
    }
    else {
      bf.write("(erleichtert um $penalty) ");
    }
    bf.write("auf ${skillName}, ");
    var roll = _random.nextInt(20) + 1;
    bf.write("$roll. ");
    bf.write("Resultat: ${taw - roll - (penalty * -1)}");

    return bf.toString();
  }
}
