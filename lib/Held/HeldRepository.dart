import 'package:collection/collection.dart';

import '../Held/Held.dart';

class HeldRepository {
  final List<Held> _helden = []; // Eine interne Liste, um Helden zu speichern

  // Methode zum Hinzufügen eines neuen Helden
  void addHeld(Held held) {
    if(!_helden.map((e) => e.uuid).contains(held.uuid)){
      _helden.add(held);
    }
  }

  // Methode zum Aktualisieren eines Helden
  void updateHeld(String heldNummer, Held updatedHeld) {
    final index = _helden.indexWhere((h) => h.heldNummer == heldNummer);
    if (index != -1) {
      _helden[index] = updatedHeld;
    }
  }

  void replaceHeld(Held originalHeld, Held newHeld) {
    final index = _helden.indexWhere((h) => h.uuid == originalHeld.uuid);
    if (index != -1) {
      _helden[index] = newHeld;
    }
  }

  // Methode zum Entfernen eines Helden
  void removeHeld(String heldNummer) {
    _helden.removeWhere((h) => h.heldNummer == heldNummer);
  }

  // Methode zum Abrufen aller Helden
  List<Held> getAllHelden() {
    return List<Held>.from(_helden);
  }

  // Methode zum Abrufen eines bestimmten Helden
  Held? getHeldByNummer(String heldNummer) {
    return _helden.firstWhereOrNull((h) => h.heldNummer == heldNummer);
  }

  Held? getHeldByGruppeId(String gruppeId){
    return _helden.firstWhereOrNull((h) => h.gruppeId == gruppeId);
  }

  List<Held> getHeldenByUser(String userId) {
    return _helden.where((h) => h.owner == userId).toList();
  }

  void addHeldenRange(List<Held> helden) {
    helden.forEach((held) {
      _helden.add(held);
    });
  }

  void clearHelden(){
    _helden.clear();
  }

}
