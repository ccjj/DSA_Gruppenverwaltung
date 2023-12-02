import 'Gruppe/GroupService.dart';
import 'Held/Held.dart';
import 'Held/HeldRepository.dart';

class HeldGroupCoordinator {
  final GroupService groupService;
  final HeldRepository heldRepository;

  HeldGroupCoordinator(this.groupService, this.heldRepository);

  Future<void> removeHeldCompletely(Held held) async {
    //TODO aws
    groupService.removeHeld(held);
    //TODO eigener aws held repo stuff xxx
    heldRepository.removeHeld(held.heldNummer);
  }
}
