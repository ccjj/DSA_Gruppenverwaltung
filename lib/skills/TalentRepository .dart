import 'dart:collection';

import 'package:collection/collection.dart';

import '../io/FileLoader.dart';
import 'Talent.dart';

class TalentRepository {
  final String filePath;
  SplayTreeSet<Talent> _talents = SplayTreeSet<Talent>((a, b) => a.compareTo(b));

  TalentRepository(this.filePath);

  SplayTreeSet<Talent> get Talente => _talents;

  Future<void> loadTalents() async {
    var jsonData = await FileLoader.loadJsonList(filePath);

    var  ttalents = jsonData.map((entry) {
      return Talent.fromJson(entry);
    });
    _talents.addAll(ttalents);
  }

  void add(Talent talent) {
    _talents.add(talent);
  }

  void remove(String name) {
    _talents.removeWhere((talent) => talent.name == name);
  }

  List<String> getTalentsAsStringList(){
    return _talents.map((talent) => talent.name).toList();
  }

  Talent? get(String name){
    if (name.toLowerCase().startsWith("sprachen")) {
      return Talent(name: name, typ: 'SPRACHEN', wurf: 'KL/IN/CH');
    }
    if (name.toLowerCase().startsWith("lesen")) {
      return Talent(name: name, typ: 'SPRACHEN', wurf: 'KL/KL/FF');
    }
    return  _talents.firstWhereOrNull((talent) => talent.name == name);
  }

}