import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dsagruppen/model/Item.dart';
import 'package:xml/xml.dart';

import '../Held/Held.dart';
import '../globals.dart';
import '../rules/Rassen.dart';

class HeldenParser {
  static Held getHeldFromXML(Uint8List fileBytes) {
    String xmlString = utf8.decode(fileBytes);
    final xmlDoc = XmlDocument.parse(xmlString);
    XmlElement heldElement;

    try {
      heldElement =
          xmlDoc.findElements('helden').first.findElements('held').first;
    } catch (_) {
      throw const FileSystemException('Datei ist keine gültige Helden-Datei');
    }

    final name = heldElement.getAttribute('name');
    if (name == null) {
      throw XmlParserException("Name des Helden konnte nicht gelesen werden");
    }

    final eigenschaftenNodes = heldElement.findElements('eigenschaften');
    final Held held = Held.empty();
    held.name = name;

    final heldKey = heldElement.getAttribute('key');
    if (name == null) {
      throw XmlParserException("ID des Helden konnte nicht gelesen werden");
    }
    held.heldNummer = heldKey!;

    var apNode = heldElement.findAllElements("abenteuerpunkte").firstOrNull;
    var ap = apNode!.getAttribute("value")!;
    held.ap = int.tryParse(ap) ?? 0;

    var rasseNode = heldElement.findAllElements("rasse").firstOrNull;
    var rasse = rasseNode!.getAttribute("string")!;
    held.rasse = rasse;

    var kulturNode = heldElement.findAllElements("kultur").firstOrNull;
    var kultur = kulturNode!.getAttribute("string")!;
    held.kultur = kultur;

    String ausbildung = "";
    var ausbildungNodes = heldElement.findAllElements("ausbildung");
    for (var ausbildungNode in ausbildungNodes) {
      var ausbildungArt = ausbildungNode.getAttribute("string");
      ausbildung += ausbildungArt ?? "";
    }
    held.ausbildung = ausbildung;

    List<String> sfs = [];
    var sfNodes = heldElement.findAllElements("sf");

    for (var sfNode in sfNodes) {
      for (var sonderfertigkeitNode
          in sfNode.findElements("sonderfertigkeit")) {
        String sfName = sonderfertigkeitNode.getAttribute("name") ?? '';

        for (var childNode in sonderfertigkeitNode.children) {
          var childName = childNode.getAttribute("name");
          if (childName != null) {
            sfName += ' ${childName}';
          }
        }

        sfs.add(sfName);
      }
    }

    held.sf = sfs;

    final aMap = <String, List<String>>{};

    for (var eigenschaft in eigenschaftenNodes) {
      for (var node in eigenschaft.findElements('eigenschaft')) {
        final n = node.getAttribute('name');
        final m = node.getAttribute('mod');
        final v = node.getAttribute('value');
        if (n != null && m != null && v != null) {
          aMap[n] = [m, v];
        }
      }
    }

    Map<String, int> talentsMap = getTalents(heldElement);
    Map<String, int> zauberMap = getZauber(heldElement);
    Map<String, int> itemMap = getItems(heldElement);

    setAttributes(held, aMap);

    var vorteile = getVorteile(heldElement);
    setWs(held, vorteile);
    held.kreuzer.value = getKreuzer(heldElement);
    held.vorteile = vorteile;
    held.talents = talentsMap;
    held.zauber = zauberMap;
    held.items = itemMap.entries
        .map((entry) => Item(name: entry.key, anzahl: entry.value))
        .toList();

    held.owner = cu.uuid;
    return held;
  }

  static Map<String, int> getTalents(XmlElement heldElement) {
    final talentsNodes = heldElement.findAllElements('talent');
    final talentsMap = <String, int>{};

    for (final node in talentsNodes) {
      final talentName = node.getAttribute('name');
      final int talentLevel =
          int.tryParse(node.getAttribute('value') ?? '0') ?? 0;
      if (talentName != null) {
        talentsMap[talentName] = talentLevel;
      }
    }

    return talentsMap;
  }

  static Map<String, int> getZauber(XmlElement heldElement) {
    final talentsNodes = heldElement.findAllElements('zauber');
    final talentsMap = <String, int>{};

    for (final node in talentsNodes) {
      final talentName = node.getAttribute('name');
      final int talentLevel =
          int.tryParse(node.getAttribute('value') ?? '0') ?? 0;
      if (talentName != null) {
        talentsMap[talentName] = talentLevel;
      }
    }

    return talentsMap;
  }

  static int getKreuzer(XmlElement heldElement) {
    final XmlElement? geldboerse =
        heldElement.findAllElements('geldboerse').firstOrNull;

    int totalKreuzer = 0;
    if (geldboerse != null) {
      for (final XmlElement muenze in geldboerse.findElements('muenze')) {
        int anzahl = int.parse(muenze.getAttribute('anzahl') ?? '0');
        String? name = muenze.getAttribute('name');

        switch (name) {
          case 'Dukat':
          case 'Dublone':
          case 'Amazonenkronen':
          case 'Dinar':
          case 'Batzen':
          case 'Horasdor':
          case 'Marawedi':
          case 'Suvar':
          case 'Witten':
          case 'Borbaradstaler':
          case 'Zwergentaler':
            totalKreuzer += anzahl * 1000;
            break;
          case 'Silbertaler':
          case 'Oreal':
          case 'Schekel':
          case 'Groschen':
          case 'Zechine':
          case 'Hedsch':
          case 'Stüber':
          case 'Zholvari':
            totalKreuzer += anzahl * 100;
            break;
          case 'Heller':
          case 'Kleiner Oreal':
          case 'Hallah':
          case 'Deut':
          case 'Muwlat':
          case "MuwlatCh'cyskl":
          case 'Flindrich':
          case 'Splitter':
            totalKreuzer += anzahl * 10;
            break;
          case 'Kreuzer':
          case 'Dirham':
          case 'Kurush':
            totalKreuzer += anzahl;
            break;
        }
      }
    }
    return totalKreuzer;
  }

  static Map<String, int> getItems(XmlElement heldElement) {
    final itemNodes = heldElement.findAllElements('gegenstand');
    final itemMap = <String, int>{};

    for (final node in itemNodes) {
      final itemName = node.getAttribute('name');
      final int anzahl = int.tryParse(node.getAttribute('anzahl') ?? '0') ?? 0;
      if (itemName != null) {
        itemMap[itemName] = anzahl;
      }
    }
    return itemMap;
  }

  static setWs(Held held, List<String> vorteile) {
    int mod = vorteile.contains("Eisern") ? 2 : 0;
    mod += vorteile.contains("Glasknochen") ? -2 : 0;
    int ws = (held.ko / 2).round() + mod;
    held.ws = ws;
  }

  static List<String> getVorteile(XmlElement heldElement) {
    final vorteileElements = heldElement.findAllElements('vorteil');

    return vorteileElements.map((vorteilElement) {
      var name = vorteilElement.getAttribute('name') ?? 'Unbekannt';
      var value = vorteilElement.getAttribute('value');
      if (value == null) {
        List<String> elements = [];
        var auswahl = vorteilElement.findElements("auswahl");
        if (auswahl != null) {
          for (var ausw in auswahl) {
            elements.insert(0, ausw.getAttribute("value")!);
          }
          value = elements.join(" ");
        }
      }
      return value != null ? "$name $value" : name;
    }).toList();
  }

  static int getAttributeOrZero(
      Map<String, List<String>> attributesMap, String attributeName) {
    return int.tryParse(attributesMap[attributeName]?[1] ?? '0') ?? 0;
  }

  static void setAttributes(
      Held held, Map<String, List<String>> attributesMap) {
    int ko = getAttributeOrZero(attributesMap, "Konstitution");
    int kk = getAttributeOrZero(attributesMap, "Körperkraft");
    int ge = getAttributeOrZero(attributesMap, "Gewandtheit");
    int mu = getAttributeOrZero(attributesMap, "Mut");
    int kl = getAttributeOrZero(attributesMap, "Klugheit");
    int intu = getAttributeOrZero(attributesMap, "Intuition");
    int ch = getAttributeOrZero(attributesMap, "Charisma");
    int ff = getAttributeOrZero(attributesMap, "Fingerfertigkeit");
    int so = getAttributeOrZero(attributesMap, "Sozialstatus");

    int at = getAttributeOrZero(attributesMap, "at");
    int pa = getAttributeOrZero(attributesMap, "pa");
    int fk = getAttributeOrZero(attributesMap, "fk");
    int ini = getAttributeOrZero(attributesMap, "ini");

    final mrArray = attributesMap['Magieresistenz']!;
    final lpArray = attributesMap['Lebensenergie']!;
    final auArray = attributesMap['Ausdauer']!;
    final aspArray = attributesMap['Astralenergie']!;
    int ke = getAttributeOrZero(
        attributesMap, "Karmaenergie"); //TODO richtige berechnung?

    held.ko = ko;
    held.kk = kk;
    held.ge = ge;
    held.mu = mu;
    held.kl = kl;
    held.intu = intu;
    held.ch = ch;
    held.ff = ff;

    Rasse? hRasse = Rassen.firstWhereOrNull((ra) => ra.name == held.rasse);
    if(hRasse != null){
      hRasse.eigenschaftsModifikationen.forEach((key, value) {
        int? attrVal = held.getAttribute(key);
        if(attrVal == null){
          print("ATTR not found: "  + key);
        }
        held.setAttribute(key, attrVal! + value);
      });
    }

    final maxLp = ((held.ko * 2 + held.kk) / 2).round() +
        int.parse(lpArray[0]) +
        int.parse(lpArray[1]);
    final maxAu = int.parse(auArray[0]) +
        int.parse(auArray[1]) +
        ((held.mu + held.ge + held.ko) / 2).round();
    //TODO vorteile, gefaeß der sterne, astrale macht etc
    final maxAsp = int.parse(aspArray[0]) +
        int.parse(aspArray[1]) +
        ((held.mu + held.intu + held.ch) / 2).round();
    final mr = int.parse(mrArray[0]) +
        int.parse(mrArray[1]) +
        ((held.mu + held.kl + held.ko) / 5).round();

    held.so = so;
    held.at = at;
    held.pa = pa;
    held.fk = fk;
    held.ini = ini;
    held.baseIni = ini;
    held.mr = mr;
    held.lp.value = maxLp;
    held.maxLp.value = maxLp;
    held.ke = ke;
    held.maxKe = ke;
    held.asp.value = maxAsp;
    held.maxAsp.value = maxAsp;
    held.au.value = maxAu;
    held.maxAu.value = maxAu;
    held.gs = 7;
  }
}
