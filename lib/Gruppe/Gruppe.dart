import 'dart:convert';

import 'package:dsagruppen/model/DsaDate.dart';
import 'package:uuid/uuid.dart';

import '../Held/Held.dart';
import '../User/User.dart';
class Gruppe {
  late String uuid = Uuid().v4();
  String name;
  DateTime erstelltAm = DateTime.now();
  DsaDate datum = DsaDate(0, 0, 1);
  String notes = "";
  List<Held> helden = [];
  List<User> users = [];
  String ownerUuid = "";



  Gruppe({
    required this.name
  });

  @override
  String toString() {
    return 'Gruppe(uuid: $uuid, name: $name, erstelltAm: $erstelltAm, datum: $datum, notes: $notes, helden: $helden, users: $users, ownerUuid: $ownerUuid)';
  }

  factory Gruppe.fromJson(Map<String, dynamic> json) {
    // Assuming the JSON keys match the property names
    /*
    List<Held> heldenList = (json['helden'] as List<dynamic>)
        .map((i) => Held.fromJson(i))
        .toList();
    User erstelltVon = User.fromJson(json['erstelltVon']);
    List<User> usersList = (json['users'] as List<dynamic>)
        .map((i) => User.fromJson(i))
        .toList();
        DsaDate datum = DsaDate.fromJson(json['datum']) ?? DsaDate(0, 0, 1);
     */
    String name = json['name'];
    String notes = json['notes'] ?? '';
    String uuid = json['id'] ?? Uuid().v4();
    String owner = json['owner'] ?? Uuid().v4();

    DsaDate datum = DsaDate.fromString(json['datum']) ?? DsaDate(0, 0, 1);

    return Gruppe(
      name: name
    )..notes = notes
      ..uuid = uuid
      ..helden = []
      ..ownerUuid = owner
      ..datum = datum;
  }

  Gruppe copyWith({
    String? uuid,
    String? name,
    DateTime? erstelltAm,
    DsaDate? datum,
    String? notes,
    List<Held>? helden,
    List<User>? users,
    String? ownerUuid,
  }) {
    return Gruppe(
      name: name ?? this.name,
    )..uuid = uuid ?? this.uuid
      ..erstelltAm = erstelltAm ?? this.erstelltAm
      ..datum = datum ?? this.datum
      ..notes = notes ?? this.notes
      ..helden = helden ?? this.helden
      ..users = users ?? this.users
      ..ownerUuid = ownerUuid ?? this.ownerUuid;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = {};

    if (uuid != null) jsonMap['id'] = uuid;
    if (name != null) jsonMap['name'] = name;
    if (datum != null) jsonMap['datum'] = datum.toString();
    if (notes != null) jsonMap['notes'] = jsonEncode(notes);

    if (users != null) {
      //jsonMap['setUserIDs'] = users.map((e) => e.uuid).toList();
    }

    if (helden != null) {
      jsonMap['helden'] = helden.map((e) => e.uuid).toList();
    }

    return jsonMap;
  }

}
