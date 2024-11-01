import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class Person {
  String uuid;
  String name;
  String heldNummer;
  String owner;
  String gruppeId;
  ValueNotifier<int> lp; // Lebenspunkte
  ValueNotifier<int> maxLp; // Maximale Lebenspunkte
  ValueNotifier<int> asp; // Astralpunkte
  ValueNotifier<int> maxAsp; // Maximale Astralpunkte
  int at; // Angriffswert
  int pa; // Parade
  int fk; // Fernkampf
  int ini; // Initiative
  int baseIni; // Initiative
  int mr; // Magieresistenz
  ValueNotifier<int> au; // Ausdauer
  ValueNotifier<int> maxAu; // Maximale Ausdauer
  int gs; // Geschwindigkeit
  int ws; // Wundschwelle
  int wunden; // Wunden

  Person({
    required this.name,
    required this.heldNummer,
    required this.owner,
    required this.gruppeId,
    required int initialLp,
    required int initialMaxLp,
    required int initialAsp,
    required int initialMaxAsp,
    required this.at,
    required this.pa,
    required this.fk,
    required this.ini,
    required this.baseIni,
    required this.mr,
    required int initialAu,
    required int initialMaxAu,
    required this.gs,
    required this.ws,
    this.wunden = 0,
  })  : uuid = Uuid().v4(),
        lp = ValueNotifier<int>(initialLp),
        maxLp = ValueNotifier<int>(initialMaxLp),
        asp = ValueNotifier<int>(initialAsp),
        maxAsp = ValueNotifier<int>(initialMaxAsp),
        au = ValueNotifier<int>(initialAu),
        maxAu = ValueNotifier<int>(initialMaxAu);
}
