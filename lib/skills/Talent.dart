import 'ISkill.dart';

class Talent implements ISkill {
  late final String name;
  late final String typ;
  late final String? wurf;
  late final String? handicap;
  late final String? seite;

  Talent({required this.name, required this.typ, required this.wurf, this.handicap, this.seite});

  factory Talent.fromJson(Map<String, dynamic> json) {
    String talentName = json['Name'].toString().replaceFirst(' / ', 'und');
    return Talent(
      name: talentName,
      typ: json['Typ'] as String,
      wurf: json['Wurf'] as String? ?? '',
      handicap: json['Behinderung'] as String? ?? '',
      seite: json['Seite'] as String?,
    );
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Talent &&
        other.name == name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }

  @override
  int compareTo(Talent other) {
    return name.compareTo(other.name);
  }
}