import 'dart:convert';

import '../model/Item.dart';
import 'Held.dart';

class UpdateHeldInput {
  String id;
  String? name;
  String? heldNummer;
  String? gruppeId;
  String? rasse;
  String? kultur;
  String? ausbildung;
  int? lp;
  int? maxLp;
  int? ap;
  int? asp;
  int? maxAsp;
  int? at;
  int? pa;
  int? fk;
  int? ini;
  int? baseIni;
  int? mr;
  int? au;
  int? maxAu;
  int? ke;
  int? maxKe;
  int? gs;
  int? ko;
  int? kk;
  int? mu;
  int? kl;
  int? ge;
  int? intu;
  int? ch;
  int? ff;
  int? so;
  int? ws;
  int? kreuzer;
  String? geburtstag;
  int? wunden;
  Map<String, int>? talents;
  List<Item>? items;
  Map<String, int>? notes;
  List<String>? vorteile;
  List<String>? sf;
  Map<String, int>? zauber;

  UpdateHeldInput({
    required this.id,
    this.name,
    this.heldNummer,
    this.gruppeId,
    this.rasse,
    this.kultur,
    this.ausbildung,
    this.lp,
    this.maxLp,
    this.ap,
    this.asp,
    this.maxAsp,
    this.at,
    this.pa,
    this.fk,
    this.ini,
    this.baseIni,
    this.mr,
    this.au,
    this.maxAu,
    this.ke,
    this.maxKe,
    this.gs,
    this.ko,
    this.kk,
    this.mu,
    this.kl,
    this.ge,
    this.intu,
    this.ch,
    this.ff,
    this.so,
    this.ws,
    this.kreuzer,
    this.geburtstag,
    this.wunden,
    this.talents,
    this.items,
    this.notes,
    this.vorteile,
    this.sf,
    this.zauber,
  });

  Map<String, dynamic> toJson() {
    //null = kein update
    //leer = update, leere map
    //nicht leer
    //String? itemsJson = jsonEncode(items) else 'items' : jsonEncode(Map()),
    bool importItems = true;

    if(items == null){
      importItems = false;
    }
    return {
      'id': id,
      if (name != null && name!.isNotEmpty) 'name': name,
      if (heldNummer != null && heldNummer!.isNotEmpty) 'heldNummer': heldNummer,
      // ... similar checks for other string fields ...
      if (gruppeId != null && gruppeId!.isNotEmpty) 'gruppeId': gruppeId,
      if (rasse != null && rasse!.isNotEmpty) 'rasse': rasse,
      if (kultur != null && kultur!.isNotEmpty) 'kultur': kultur,
      if (ausbildung != null && ausbildung!.isNotEmpty) 'ausbildung': ausbildung,
      // ... similar checks for integer fields ...
      if (lp != null) 'lp': lp,
      if (maxLp != null) 'maxLp': maxLp,
      if (ap != null) 'ap': ap,
      if (asp != null) 'asp': asp,
      if (maxAsp != null) 'maxAsp': maxAsp,
      if (at != null) 'at': at,
      if (pa != null) 'pa': pa,
      if (fk != null) 'fk': fk,
      if (ini != null) 'ini': ini,
      if (baseIni != null) 'baseIni': baseIni,
      if (mr != null) 'mr': mr,
      if (au != null) 'au': au,
      if (maxAu != null) 'maxAu': maxAu,
      if (ke != null) 'ke': ke,
      if (maxKe != null) 'maxKe': maxKe,
      if (gs != null) 'gs': gs,
      if (ko != null) 'ko': ko,
      if (kk != null) 'kk': kk,
      if (mu != null) 'mu': mu,
      if (kl != null) 'kl': kl,
      if (ge != null) 'ge': ge,
      if (intu != null) 'intu': intu,
      if (ch != null) 'ch': ch,
      if (ff != null) 'ff': ff,
      if (so != null) 'so': so,
      if (ws != null) 'ws': ws,
      if (kreuzer != null) 'kreuzer': kreuzer,
      if (geburtstag != null) 'geburtstag': geburtstag,
      if (wunden != null) 'wunden': wunden,
      // ... similar checks for Map or List fields ...
      if (talents != null && talents!.isNotEmpty) 'talents': jsonEncode(talents),
      if (importItems) 'items' : jsonEncode(items),
      if (notes != null && notes!.isNotEmpty) 'notes': jsonEncode(notes),
      if (vorteile != null && vorteile!.isNotEmpty) 'vorteile': jsonEncode(vorteile),
      if (sf != null && sf!.isNotEmpty) 'sf': jsonEncode(sf),
      if (zauber != null && zauber!.isNotEmpty) 'zauber': jsonEncode(zauber),
    };
  }

  static UpdateHeldInput createUpdateInputFromHeldDifference(Held originalHeld, Held newHeld) {
    UpdateHeldInput input = UpdateHeldInput(id: originalHeld.uuid);

    if (originalHeld.name != newHeld.name) input.name = newHeld.name;
    if (originalHeld.heldNummer != newHeld.heldNummer) input.heldNummer = newHeld.heldNummer;
    if (originalHeld.gruppeId != newHeld.gruppeId) input.gruppeId = newHeld.gruppeId;
    if (originalHeld.rasse != newHeld.rasse) input.rasse = newHeld.rasse;
    if (originalHeld.kultur != newHeld.kultur) input.kultur = newHeld.kultur;
    if (originalHeld.ausbildung != newHeld.ausbildung) input.ausbildung = newHeld.ausbildung;
    if (originalHeld.lp.value != newHeld.lp.value) input.lp = newHeld.lp.value;
    if (originalHeld.maxLp.value != newHeld.maxLp.value) input.maxLp = newHeld.maxLp.value;
    if (originalHeld.ap != newHeld.ap) input.ap = newHeld.ap;
    if (originalHeld.asp.value != newHeld.asp.value) input.asp = newHeld.asp.value;
    if (originalHeld.maxAsp.value != newHeld.maxAsp) input.maxAsp = newHeld.maxAsp.value;
    if (originalHeld.at != newHeld.at) input.at = newHeld.at;
    if (originalHeld.pa != newHeld.pa) input.pa = newHeld.pa;
    if (originalHeld.fk != newHeld.fk) input.fk = newHeld.fk;
    if (originalHeld.ini != newHeld.ini) input.ini = newHeld.ini;
    if (originalHeld.baseIni != newHeld.baseIni) input.baseIni = newHeld.baseIni;
    if (originalHeld.mr != newHeld.mr) input.mr = newHeld.mr;
    if (originalHeld.au.value != newHeld.au.value) input.au = newHeld.au.value;
    if (originalHeld.maxAu.value != newHeld.maxAu.value) input.maxAu = newHeld.maxAu.value;
    if (originalHeld.ke != newHeld.ke) input.ke = newHeld.ke;
    if (originalHeld.maxKe != newHeld.maxKe) input.maxKe = newHeld.maxKe;
    if (originalHeld.gs != newHeld.gs) input.gs = newHeld.gs;
    if (originalHeld.ko != newHeld.ko) input.ko = newHeld.ko;
    if (originalHeld.kk != newHeld.kk) input.kk = newHeld.kk;
    if (originalHeld.mu != newHeld.mu) input.mu = newHeld.mu;
    if (originalHeld.kl != newHeld.kl) input.kl = newHeld.kl;
    if (originalHeld.ge != newHeld.ge) input.ge = newHeld.ge;
    if (originalHeld.intu != newHeld.intu) input.intu = newHeld.intu;
    if (originalHeld.ch != newHeld.ch) input.ch = newHeld.ch;
    if (originalHeld.ff != newHeld.ff) input.ff = newHeld.ff;
    if (originalHeld.so != newHeld.so) input.so = newHeld.so;
    if (originalHeld.ws != newHeld.ws) input.ws = newHeld.ws;
    if (originalHeld.kreuzer != newHeld.kreuzer) input.kreuzer = newHeld.kreuzer.value;
    if (originalHeld.wunden != newHeld.wunden) input.wunden = newHeld.wunden;
    if (originalHeld.geburtstag != newHeld.geburtstag) input.geburtstag = newHeld.geburtstag;
    if (originalHeld.talents != newHeld.talents) input.talents = newHeld.talents;
    if (originalHeld.items.isEmpty) {input.items = newHeld.items;} else {input.items = null;};
    if (originalHeld.notes != newHeld.notes) input.notes = newHeld.notes;
    if (originalHeld.vorteile != newHeld.vorteile) input.vorteile = newHeld.vorteile;
    if (originalHeld.sf != newHeld.sf) input.sf = newHeld.sf;
    if (originalHeld.zauber != newHeld.zauber) input.zauber = newHeld.zauber;

    return input;
  }
}
