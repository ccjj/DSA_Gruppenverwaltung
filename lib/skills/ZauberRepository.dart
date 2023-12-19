import 'dart:collection';

import 'package:collection/collection.dart';

import '../io/FileLoader.dart';
import 'Zauber.dart';

class ZauberRepository {
  final String filePath;
  SplayTreeSet<Zauber> _Zauber = SplayTreeSet<Zauber>((a, b) => a.compareTo(b));

  ZauberRepository(this.filePath);

  SplayTreeSet<Zauber> get Zaubers => _Zauber;

  Future<void> loadZaubers() async {
    var jsonData = await FileLoader.loadJsonList(filePath);
    Iterable<Zauber>  tzauber = jsonData.map((entry) {
      return Zauber.fromJson(entry);
    });
    tzauber.forEach((element) {
      _Zauber.add(element);
    });
    //_Zauber.addAll(tzauber);
  }

  // Add other methods to manage Zaubers (add, remove, update) as needed
  // Example: Add a new Zauber
  void add(Zauber Zauber) {
    _Zauber.add(Zauber);
  }

  // Example: Remove a Zauber by name
  void remove(String name) {
    _Zauber.removeWhere((Zauber) => Zauber.name == name);
  }

  Zauber? get(String name){
    return _Zauber.firstWhereOrNull((zauber) => zauber.name == name);
  }

}