import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dsagruppen/Gruppe/GroupAmplifyService.dart';
import 'package:dsagruppen/Gruppe/Gruppe.dart';
import 'package:dsagruppen/Gruppe/GruppeRepository.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../Held/Held.dart';
import '../globals.dart';

class GroupService {
  final GruppeRepository _groupRepository;
  final GroupAmplifyService _groupAmplifyService;

  GroupService(this._groupRepository, this._groupAmplifyService);

  Future<bool> addUserToGroup(String gruppeId, String userId) async {
    return await _groupAmplifyService.createGruppeUser(gruppeId, userId);
  }

  Future<bool> createGroup(String name) async {
    Gruppe? createdGroup = await _groupAmplifyService.createGruppe(name);
    if (createdGroup != null) {
      bool groupUser = await addUserToGroup(createdGroup.uuid, cu.uuid);
      if(groupUser == true){
        createdGroup.users.add(cu);
        _groupRepository.addGruppe(createdGroup);
        return true;
      }
      //TODO wie beim get.
      //gp holen, gp user holen, in gp.user hinzufügen?
      //direkt gp.user als string[]?
      /*
      createdGroup.users.add(cu);
      createdGroup = await _groupAmplifyService.updateGruppe(createdGroup);
      if(createdGroup != null){
        _groupRepository.addGruppe(createdGroup);
        print(jsonEncode("created"));
        print(jsonEncode(createdGroup));
        return true;
      }
       */

      EasyLoading.showError("Gruppe konnte nicht erstellt werden");
    }
    return false;
  }

  Future<void> getGruppen()async {
    List<Gruppe>? gruppen = await _groupAmplifyService.getGruppen();
    if(gruppen != null){
      //TODO if not exist
      _groupRepository.addGruppeRange(gruppen);
    } else {
      safePrint("keine gruppen");
    }
  }

  Future<bool> deleteGruppe(String id) async {
    Gruppe? gruppe = _groupRepository.getGruppeByUUID(id);
    if(gruppe == null){
      return false;
    }
    var deleted = await _groupAmplifyService.deleteGruppe(id);
    if(deleted){
      _groupRepository.deleteGruppe(id);
      await _groupAmplifyService.deleteGruppeUserByGroup(id);
      return true;
    }
    return false;
  }

  bool isCurrentUserOwner(Gruppe gruppe){
    return gruppe.ownerUuid == cu.uuid;
  }

  void removeHeld(Held held){
    _groupRepository.getAllGruppen().forEach((gruppe) {
      gruppe.helden.removeWhere((h) => h.heldNummer == held.heldNummer);
    });
  }
}
