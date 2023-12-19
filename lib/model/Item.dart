class Item {
  String name;
  int anzahl;
  String? beschreibung;

  Item({required this.name, required this.anzahl, this.beschreibung});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'anzahl': anzahl,
      'beschreibung': beschreibung
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        name: json['name'],
        anzahl: json['anzahl'],
        beschreibung: json['beschreibung']
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Item &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              anzahl == other.anzahl &&
              beschreibung == other.beschreibung;

  @override
  int get hashCode =>
      name.hashCode ^ anzahl.hashCode ^ beschreibung.hashCode;
}
