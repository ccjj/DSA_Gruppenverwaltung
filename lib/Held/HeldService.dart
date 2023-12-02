import '../globals.dart';
import 'Held.dart';
import 'HeldAmplifyService.dart';
import 'HeldRepository.dart';
import 'UpdateHeldInput.dart';

class HeldService {
  final HeldRepository heldRepository;
  final HeldAmplifyService heldAmplifyService;

  HeldService(this.heldRepository, this.heldAmplifyService);

  Future<Held?> createHeld(Held held) async {
    var createdHeld = await heldAmplifyService.createHeld(held);
    if(createdHeld != null){
      heldRepository.addHeld(held);
      return held;
    }
    return null;
  }

  //not used TODO
  Future<void> updateTODOFullHeld(String heldNummer, Held updatedHeld) async {
    //await heldAmplifyService.updateHeld(heldNummer, updatedHeld);
    heldRepository.updateHeld(heldNummer, updatedHeld);
  }

  Future<void> updateHeld(Held? originalHeld, Held? newHeld) async {
    if(originalHeld == null || newHeld == null) {
      return;
    }
    var updateInput = UpdateHeldInput.createUpdateInputFromHeldDifference(originalHeld, newHeld);
    print(updateInput.toJson());
    await heldAmplifyService.updateHeld(updateInput);
    heldRepository.replaceHeld(originalHeld, newHeld);
  }

  Future<void> updateHeldFromInput(Held originalHeld, UpdateHeldInput updateInput) async {
    await heldAmplifyService.updateHeld(updateInput);
    //heldRepository.replaceHeld(originalHeld, newHeld);
  }

  Future<void> deleteHeld(String heldNummer) async {
    await heldAmplifyService.deleteHeld(heldNummer);
    heldRepository.removeHeld(heldNummer);
  }

  Future<List<Held>> getAllHelden() async {
    var helden = await heldAmplifyService.getAllHelden();
    print("AWS: " + helden.length.toString());
    heldRepository.addHeldenRange(helden);
    //TODO only non existing
    //TODO only helden for group id
    return heldRepository.getAllHelden();
  }

  Future<List<Held>?> getHeldenByGroupId(String groupId) async {
    var heldenIds = await getIt<HeldAmplifyService>().getHeldenIdsByGruppeId(groupId);
    if(heldenIds == null) return null;

    List<Held> result = [];
    for (var hid in heldenIds) {
      var held = await getIt<HeldAmplifyService>().getHeldById(hid);
      if(held != null) {
        result.add(held);
      }
    }

    if(result.isNotEmpty){
      //getIt<HeldRepository>().addHeldenRange(result);
      return result;
    }
  return null;
  }
}
