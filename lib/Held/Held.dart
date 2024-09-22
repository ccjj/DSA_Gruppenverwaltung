import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../globals.dart';
import '../model/Item.dart';

class Held {
  late String uuid = Uuid().v4();
  String name;
  String heldNummer;
  String owner;
  String gruppeId;
  String rasse;
  String kultur;
  String ausbildung;
  ValueNotifier<int> lp; // Lebenspunkte
  ValueNotifier<int> maxLp; // Maximale Lebenspunkte
  int ap; // Abenteuerpunkte
  ValueNotifier<int> asp; // Astralpunkte
  ValueNotifier<int> maxAsp; // Astralpunkte
  int at; // Angriffswert
  int pa; // Parade
  int fk; //fernkampf
  int ini; // Initiative
  int baseIni; // Basisinitiative
  int mr; // Magieresistenz
  ValueNotifier<int> au; // Ausdauer
  ValueNotifier<int> maxAu; // Ausdauer
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
  ValueNotifier<int> kreuzer;
  int wunden;
  String geburtstag;
  Map<String, int> talents; // Map of talents (talent name to talent level)
  List<Item> items;
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
    required this.ws,
    required this.kreuzer,
    required this.wunden,
    required this.geburtstag,
    required this.talents,
    required this.gruppeId,
    required this.ke,
    required this.maxKe,
    required this.fk,
    required this.so,
    this.notes = const {},
    this.zauber = const {},
    this.vorteile = const [],
    this.sf = const [],
    this.items = const []
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['name'] = name;
    data['heldNummer'] = heldNummer;
    data['gruppeID'] = gruppeId;
    data['rasse'] = rasse;
    data['kultur'] = kultur;
    data['ausbildung'] = ausbildung;
    data['lp'] = lp.value;
    data['maxLp'] = maxLp.value;
    data['ap'] = ap;
    data['asp'] = asp.value;
    data['maxAsp'] = maxAsp.value;
    data['at'] = at;
    data['pa'] = pa;
    data['fk'] = fk;
    data['ini'] = ini;
    data['baseIni'] = baseIni;
    data['mr'] = mr;
    data['au'] = au.value;
    data['maxAu'] = maxAu.value;
    data['ke'] = ke;
    data['maxKe'] = maxKe;
    data['gs'] = gs;
    data['ko'] = ko;
    data['kk'] = kk;
    data['mu'] = mu;
    data['kl'] = kl;
    data['ge'] = ge;
    data['so'] = so;
    data['intu'] = intu;
    data['ch'] = ch;
    data['ff'] = ff;
    data['ws'] = ws;
    data['kreuzer'] = kreuzer.value;
    data['wunden'] = wunden;
    data['geburtstag'] = geburtstag;
    if (talents.isNotEmpty) data['talents'] = jsonEncode(talents);
    if (items.isNotEmpty) data['items'] = jsonEncode(items);
    //if (notes != null) data['notes'] = jsonEncode(notes); //TODO
    data['zauber'] = jsonEncode(zauber);
    data['vorteile'] = jsonEncode(vorteile);
    data['sf'] = jsonEncode(sf);
    return data;
  }

  static Held fromJson(Map<String, dynamic> json) {
    //var _owner = json['benutzer'] as String? ?? '';
    //var user = getIt<UserRepository>().getUserById(_owner);//TODO
    var titems = json['items'];
    List<Item> tItemList = [];
    if(titems != null) {
      bool isParsed = true;
      try {
        List<dynamic> jsonList = jsonDecode(titems);
        List<Item> items = jsonList.map((jsonItem) => Item.fromJson(jsonItem))
            .toList();
        tItemList = items;
      } catch (ex) {
        isParsed = false;
      }
      if (!isParsed) {
        try {
          //for legacy data
          Map<String, dynamic> jsonMap = jsonDecode(titems);
          List<Item> items = jsonMap.entries.map((entry) => Item(name: entry.key, anzahl: entry.value)).toList();
          tItemList = items;
        } catch(ex){
          print(ex);
          print(titems);
        }
        //Map<String, int> legacyItemList = Map<String, int>.from(jsonDecode(titems));
       // legacyItemList.entries.forEach((element) {
       //   tItemList.add(Item(name: element.key, anzahl: element.value));
       // });
      }
    }

    String uuid = json['id'] ?? Uuid().v4();
    int tlp = json['lp'] as int? ?? 0;
    int tmaxLp = json['maxLp'] as int? ?? 0;
    int tasp = json['asp'] as int? ?? 0;
    int tmaxAsp = json['maxAsp'] as int? ?? 0;
    int tau = json['au'] as int? ?? 0;
    int tmaxAu = json['maxAu'] as int? ?? 0;
    int tkreuzer = json['kreuzer'] as int? ?? 0;
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
      kreuzer: ValueNotifier(tkreuzer),
      wunden: json['wunden'] as int? ?? 0,
      geburtstag: json['geburtstag'] as String? ?? '',
      talents: json['talents'] != null
          ? Map<String, int>.from(jsonDecode(json['talents']))
          : {},
      items: tItemList,
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
        kreuzer = ValueNotifier(0),
        wunden = 0,
        geburtstag = '',
        talents = {},
        items = [],
        notes = {},
        zauber = {},
        vorteile = [],
        sf = [];


  int? getAttribute(String name) {
    switch (name) {
      case 'at':
        return at;
      case 'pa':
        return pa;
      case 'fk':
        return fk;
      case 'mr':
        return mr;
      case 'ko':
        return ko;
      case 'kk':
        return kk;
      case 'mu':
        return mu;
      case 'kl':
        return kl;
      case 'ge':
        return ge;
      case 'in':
        return intu;
      case 'ch':
        return ch;
      case 'ff':
        return ff;
      case 'lp':
        return lp.value;
      case 'au':
        return au.value;
      default:
        return null;
    }
  }

  void setAttribute(String name, int value) {
    switch (name) {
      case 'at':
        at = value;
        break;
      case 'pa':
        pa = value;
        break;
      case 'fk':
        fk = value;
        break;
      case 'mr':
        mr = value;
        break;
      case 'ko':
        ko = value;
        break;
      case 'kk':
        kk = value;
        break;
      case 'mu':
        mu = value;
        break;
      case 'kl':
        kl = value;
        break;
      case 'ge':
        ge = value;
        break;
      case 'in':
        intu = value;
        break;
      case 'ch':
        ch = value;
        break;
      case 'ff':
        ff = value;
      case 'lp':
        lp.value = value;
      case 'au':
        au.value = value;
        break;
      default:
        print("unbekanntes attribut: " + name);
        break;
    }
  }


  static Map<String, int> attributeNameMap(Held held) {
      return {
        'Mut (MU)': held.mu,
        'Klugheit (KL)': held.kl,
        'Intuition (IN)': held.intu,
        'Charisma (CH)': held.ch,
        'Fingerfertigkeit (FF)': held.ff,
        'Gewandheit (GE)': held.ge,
        'Kostitution (KO)': held.ko,
        'Körperkraft (KK)': held.kk,
        'Sozialstatus (SO)': held.so,
        'Geschwindigkeit (GS)': held.gs
      };
    }
}
