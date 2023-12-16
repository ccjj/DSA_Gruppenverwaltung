import 'dart:collection';

import '../io/FileLoader.dart';
import 'Talent.dart';
import 'package:collection/collection.dart';

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

  Talent? get(String name){
    var result =  _talents.firstWhereOrNull((talent) => talent.name == name);
    return result;
  }

}