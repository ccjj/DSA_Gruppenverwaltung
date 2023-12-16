import 'package:dsagruppen/actions/ActionSource.dart';
import 'Action.dart';

class ActionStack {
  List<Action> clientActionStack = [];
  int maxSize = 30;
  Duration maxAge = const Duration(seconds: 1);

  //todo object, idd
  //or action?
  void handleUserAction(dynamic newValue, String field, ActionSource source, Function action) {
    bool shouldHandle = shouldHandleSubscriptionUpdate(newValue, field, source);
    if(!shouldHandle) return;
    Action userAction = Action(value: newValue, field: field, source: source);
    if(source == ActionSource.client){
      clientActionStack.insert(0, userAction);
      if (clientActionStack.length > maxSize) {
        clientActionStack.removeLast();
      }
    }
    action.call();
  }

  bool shouldHandleSubscriptionUpdate(dynamic newValue, String field, ActionSource source) {
    Action subAction = Action(value: newValue, field: field, source: source);
    if (source == ActionSource.server && containsRecentUserAction(subAction)) {
      print("SKIP SUB");
      return false;
    }
    if(source == ActionSource.client){
      return false;
    }
    return true;
  }

  bool containsRecentUserAction(Action action) {
    DateTime threshold = DateTime.now().subtract(maxAge);
    return clientActionStack.any(
            (a) =>
        a.value == action.value &&
            a.field == action.field &&
            a.timestamp.isAfter(threshold) &&
        a.timestamp.isBefore(action.timestamp)
    );
  }
}
