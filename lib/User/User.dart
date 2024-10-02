import 'package:uuid/uuid.dart';

import '../Held/Held.dart';

class User {
  final String uuid;
  String name;
  final String email;

  Held? aktuellerHeld;

  User({required this.name, required this.email, String? uuid, String? awsDbId})
      : uuid = uuid ?? Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'email': email,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
      uuid: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is User && other.uuid == uuid;
  }

  @override
  int get hashCode {
    return uuid.hashCode;
  }

}
