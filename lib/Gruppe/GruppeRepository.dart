import 'package:collection/collection.dart';

import 'Gruppe.dart';

class GruppeRepository {
  final List<Gruppe> _gruppen = [];

  void addGruppe(Gruppe gruppe) {
    _gruppen.add(gruppe);
  }

  void addGruppeRange(List<Gruppe> gruppen) {
    gruppen.forEach((gruppe) {
      _gruppen.add(gruppe);
    });
  }

  void clearGruppen(){
    _gruppen.clear();
  }

  List<Gruppe> getAllGruppen() {
    return _gruppen;
  }

  Gruppe? getGruppeByUUID(String uuid) {
    return _gruppen.firstWhereOrNull(
      (gruppe) => gruppe.uuid == uuid
    );
  }

  void updateGruppe(Gruppe updatedGruppe) {
    final index = _gruppen.indexWhere((gruppe) => gruppe.name == updatedGruppe.name);
    if (index != -1) {
      _gruppen[index] = updatedGruppe;
    }
  }

  void deleteGruppe(String uuid) {
    _gruppen.removeWhere((gruppe) => gruppe.uuid == uuid);
  }
}
