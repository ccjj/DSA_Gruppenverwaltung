import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../User/UserRepository.dart';
import '../globals.dart';

class Held {
  late String uuid = Uuid().v4();
  String name;
  String heldNummer;
  String owner;
  String gruppeId;
  String rasse;
  String kultur;
  String ausbildung;
  ValueNotifier lp; // Lebenspunkte
  ValueNotifier maxLp; // Maximale Lebenspunkte
  int ap; // Abenteuerpunkte
  ValueNotifier asp; // Astralpunkte
  ValueNotifier maxAsp; // Astralpunkte
  int at; // Angriffswert
  int pa; // Parade
  int fk; //fernkampf
  int ini; // Initiative
  int baseIni; // Basisinitiative
  int mr; // Magieresistenz
  ValueNotifier au; // Ausdauer
  ValueNotifier maxAu; // Ausdauer
  int ke; //Karmalenergie
  int maxKe;
  int gs; // Geschwindigkeit
  int ko; // Konstitution
  int kk; // Körperkraft
  int mu; // Mut
  int kl; // Klugheit
  int ge; // Gewandtheit
  int intu; // Intuition
  int ch; // Charisma
  int ff; // Fingerfertigkeit
  int so; // sozialstatus
  int ws; // Wundschwelle
  Map<String, int> talents; // Map of talents (talent name to talent level)
  Map<String, int> items;
  Map<String, int> notes;
  List<String> vorteile;
  List<String> sf;
  Map<String, int> zauber;

  Held({
    required this.name,
    required this.heldNummer,
    required this.owner,
    required this.rasse,
    required this.kultur,
    required this.ausbildung,
    required this.lp,
    required this.maxLp,
    required this.au,
    required this.maxAu,
    required this.ap,
    required this.asp,
    required this.maxAsp,
    required this.at,
    required this.pa,
    required this.ini,
    required this.baseIni,
    required this.mr,
    required this.gs,
    required this.ko,
    required this.kk,
    required this.mu,
    required this.kl,
    required this.ge,
    required this.intu,
    required this.ch,
    required this.ff,
    required this.ws, required this.talents,
    required this.items,
    required this.gruppeId,
    required this.ke,
    required this.maxKe,
    required this.fk,
    required this.so,
    this.notes = const {},
    this.zauber = const {},
    this.vorteile = const [],
    this.sf = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (heldNummer != null) data['heldNummer'] = heldNummer;
    if (gruppeId != null) data['gruppeID'] = gruppeId;
    if (rasse != null) data['rasse'] = rasse;
    if (kultur != null) data['kultur'] = kultur;
    if (ausbildung != null) data['ausbildung'] = ausbildung;
    if (lp != null) data['lp'] = lp.value;
    if (maxLp != null) data['maxLp'] = maxLp.value;
    if (ap != null) data['ap'] = ap;
    if (asp != null) data['asp'] = asp.value;
    if (maxAsp != null) data['maxAsp'] = maxAsp.value;
    if (at != null) data['at'] = at;
    if (pa != null) data['pa'] = pa;
    if (pa != null) data['fk'] = fk;
    if (ini != null) data['ini'] = ini;
    if (baseIni != null) data['baseIni'] = baseIni;
    if (mr != null) data['mr'] = mr;
    if (au != null) data['au'] = au.value;
    if (maxAu != null) data['maxAu'] = maxAu.value;
    if (ke != null) data['ke'] = ke;
    if (maxKe != null) data['maxKe'] = maxKe;
    if (gs != null) data['gs'] = gs;
    if (ko != null) data['ko'] = ko;
    if (kk != null) data['kk'] = kk;
    if (mu != null) data['mu'] = mu;
    if (kl != null) data['kl'] = kl;
    if (ge != null) data['ge'] = ge;
    if (so != null) data['so'] = so;
    if (intu != null) data['intu'] = intu;
    if (ch != null) data['ch'] = ch;
    if (ff != null) data['ff'] = ff;
    if (ws != null) data['ws'] = ws;
    if (talents != null && talents.isNotEmpty) data['talents'] = jsonEncode(talents);
    if (items != null && items.isNotEmpty) data['items'] = jsonEncode(items);
    if (notes != null) data['notes'] = jsonEncode(notes);
    if (zauber != null) data['zauber'] = jsonEncode(zauber);
    if (vorteile != null) data['vorteile'] = jsonEncode(vorteile);
    if (sf != null) data['sf'] = jsonEncode(sf);
    return data;
  }

  static Held fromJson(Map<String, dynamic> json) {
    var _owner = json['benutzer'] as String? ?? '';
    var user = getIt<UserRepository>().getUserById(_owner);//TODO
    String uuid = json['id'] ?? Uuid().v4();
    int tlp = json['lp'] as int? ?? 0;
    int tmaxLp = json['maxLp'] as int? ?? 0;
    int tasp = json['asp'] as int? ?? 0;
    int tmaxAsp = json['maxAsp'] as int? ?? 0;
    int tau = json['au'] as int? ?? 0;
    int tmaxAu = json['maxAu'] as int? ?? 0;
    //TODO throw exception, dont import
    return Held(
      name: json['name'] as String? ?? '',
      heldNummer: json['heldNummer'] as String? ?? '',
      gruppeId: json['gruppeID'] as String? ?? Uuid().v4(),
      owner: json['owner'] as String? ?? cu.uuid,
      rasse: json['rasse'] as String? ?? '',
      kultur: json['kultur'] as String? ?? '',
      ausbildung: json['ausbildung'] as String? ?? '',
      lp: ValueNotifier(tlp),
      maxLp: ValueNotifier(tmaxLp),
      ap: json['ap'] as int? ?? 0,
      asp: ValueNotifier(tasp),
      maxAsp: ValueNotifier(tmaxAsp),
      ke: json['ke'] as int? ?? 0,
      maxKe: json['maxKe'] as int? ?? 0,
      at: json['at'] as int? ?? 0,
      pa: json['pa'] as int? ?? 0,
      fk: json['fk'] as int? ?? 0,
      ini: json['ini'] as int? ?? 0,
      baseIni: json['baseIni'] as int? ?? 0,
      mr: json['mr'] as int? ?? 0,
      au: ValueNotifier(tau),
      maxAu: ValueNotifier(tmaxAu),
      gs: json['gs'] as int? ?? 0,
      ko: json['ko'] as int? ?? 0,
      kk: json['kk'] as int? ?? 0,
      mu: json['mu'] as int? ?? 0,
      kl: json['kl'] as int? ?? 0,
      ge: json['ge'] as int? ?? 0,
      intu: json['intu'] as int? ?? 0,
      ch: json['ch'] as int? ?? 0,
      ff: json['ff'] as int? ?? 0,
      so: json['so'] as int? ?? 0,
      ws: json['ws'] as int? ?? 0,
      talents: json['talents'] != null
          ? Map<String, int>.from(jsonDecode(json['talents']))
          : {},
      items: json['items'] != null
          ? Map<String, int>.from(jsonDecode(json['items']))
          : {},
      notes: json['notes'] != null
          ? Map<String, int>.from(jsonDecode(json['notes']))
          : {},
      vorteile: json['vorteile'] != null
          ? List<String>.from(jsonDecode(json['vorteile']))
          : [],
      zauber: json['zauber'] != null
          ? Map<String, int>.from(jsonDecode(json['zauber']))
          : {},
      sf: json['sf'] != null
          ? List<String>.from(jsonDecode(json['sf']))
          : [],
    )..uuid = uuid;
  }

  @override
  bool operator ==(Object other) {
    return other is Held && other.uuid == uuid;
  }

  @override
  int get hashCode {
    return uuid.hashCode;
  }


  Held.empty()
      : name = '',
        heldNummer = '',
        gruppeId = '',
        owner = cu.uuid,
        rasse = "",
        kultur = "",
        ausbildung = "",
        lp = ValueNotifier(0),
        maxLp = ValueNotifier(0),
        ap = 0,
        asp = ValueNotifier(0),
        maxAsp = ValueNotifier(0),
        ke = 0,
        maxKe = 0,
        at = 0,
        pa = 0,
        fk = 0,
        ini = 0,
        baseIni = 0,
        mr = 0,
        au = ValueNotifier(0),
        maxAu = ValueNotifier(0),
        gs = 0,
        ko = 0,
        kk = 0,
        mu = 0,
        kl = 0,
        ge = 0,
        intu = 0,
        ch = 0,
        ff = 0,
        so = 0,
        ws = 0,
        talents = {},
        items = {},
        notes = {},
        zauber = {},
        vorteile = [],
        sf = [];


}
