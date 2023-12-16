import 'ISkill.dart';

class Zauber implements ISkill {
  late final String name;
  late final String? wurf;
  late final String? handicap;
  late final String? seite;

  Zauber({required this.name, required this.wurf, this.handicap, this.seite});

  factory Zauber.fromJson(Map<String, dynamic> json) {
      return Zauber(
        name: json['Name'] as String,
        wurf: json['Wurf'] as String,
        seite: json['Seite'] as String,
        handicap: json['Erschwernis'] as String,
      );
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Zauber &&
        other.name == name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }

  @override
  int compareTo(Zauber other) {
    return name.compareTo(other.name);
  }
}