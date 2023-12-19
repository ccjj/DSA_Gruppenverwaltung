

class UpdateGruppeInput {
  String id;
  String? name;
  DateTime? treffenAm;
  String? datum;
  String? bemerkung;
  String? gruppeNotesId;

  UpdateGruppeInput({
    required this.id,
    this.name,
    this.treffenAm,
    this.datum,
    this.bemerkung,
    this.gruppeNotesId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.name != null) {
      data['name'] = this.name;
    }
    if (this.treffenAm != null) {
      data['treffenAm'] = "${this.treffenAm!.year.toString().padLeft(4, '0')}-${this.treffenAm!.month.toString().padLeft(2, '0')}-${this.treffenAm!.day.toString().padLeft(2, '0')}";
    }
    if (this.datum != null) {
      data['datum'] = this.datum;
    }
    if (this.bemerkung != null) {
      data['bemerkung'] = this.bemerkung;
    }
    if (this.gruppeNotesId != null) {
      data['gruppeNotesId'] = this.gruppeNotesId;
    }
    return data;
  }
}
