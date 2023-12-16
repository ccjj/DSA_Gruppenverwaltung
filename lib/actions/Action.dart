import 'ActionSource.dart';

class Action {
    dynamic value;
    DateTime timestamp = DateTime.now();
    ActionSource source;
    String field;

    Action({required this.value, required this.field, required this.source});

}