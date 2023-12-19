import 'package:dsagruppen/skills/ZauberRepository.dart';

import '../Held/Held.dart';
import '../globals.dart';
import '../skills/ISkill.dart';
import '../skills/Talent.dart';
import '../skills/TalentRepository .dart';
import '../skills/Zauber.dart';

class RuleProvider {

  static int? getTaw(Held held, ISkill skill){
    if(skill is! Talent && skill is! Zauber)
    {
      print(skill.runtimeType);
      throw Exception("Class implementation not found for skill");
    }
    Map<String, int> sourceMap;
    if(skill is Zauber){
      sourceMap = held.zauber;
    } else{
      sourceMap = held.talents;
    }
    int? taw = sourceMap[skill.name];
    return taw;
  }

  static Iterable<String> getPropsToRoll(ISkill skill){
    return skill.wurf!.split('/').map((e) => e.toLowerCase());
  }

  static ISkill? getSkillByName(String name){
    Talent? talent = getIt<TalentRepository>().get(name);
    if(name.toLowerCase().startsWith("sprachen")){
      talent = Talent(name: name, typ: 'SPRACHEN', wurf: 'KL/IN/CH', seite: "WdS32");
    }
    if(name.toLowerCase().startsWith("lesen")){
      talent = Talent(name: name, typ: 'SPRACHEN', wurf: 'KL/KL/FF', seite: "WdS32");
    }
    if(talent != null){
      return talent;
    }
    return getIt<ZauberRepository>().get(name);
  }

  static int getModificator(ISkill? skill, int penalty) {
    if(skill is Talent){
      var typ = (skill as Talent).typ;
      if(typ == "NAHKAMPF"){
        //return held
      }
      if(typ == "FERNKAMPF"){
        //TODO
      }
    }
    return penalty;
  }


}