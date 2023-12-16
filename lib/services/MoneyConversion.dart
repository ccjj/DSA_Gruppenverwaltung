class MoneyConversion {

  static String toDSACurrency(int kreuzer) {
    int dukaten = kreuzer ~/ 1000;
    int remainingAfterDukaten = kreuzer % 1000;

    int silbertaler = remainingAfterDukaten ~/ 100;
    int remainingAfterSilbertaler = remainingAfterDukaten % 100;

    int heller = remainingAfterSilbertaler ~/ 10;
    int remainingKreuzer = remainingAfterSilbertaler % 10;

    List<String> parts = [];
    if (dukaten > 0) parts.add('$dukaten Dukaten');
    if (silbertaler > 0) parts.add('$silbertaler Silbertaler');
    if (heller > 0) parts.add('$heller Heller');
    if (remainingKreuzer > 0) parts.add('$remainingKreuzer Kreuzer');

    return parts.isNotEmpty ? parts.join(', ') : '0';
  }

  static int calcKreuzer(int dukaten, int silber, int heller, int kreuzer){
    int totalKreuzer = dukaten * 1000 + silber * 100 + heller * 10 + kreuzer;
    return totalKreuzer;
  }

  static int calcKreuzerByStr(String dukaten, String silber, String heller, String kreuzer){
    int _dukaten = int.tryParse(dukaten) ?? 0;
    int _silber = int.tryParse(silber) ?? 0;
    int _heller = int.tryParse(heller) ?? 0;
    int _kreuzer = int.tryParse(kreuzer) ?? 0;
    return calcKreuzer(_dukaten, _silber, _heller, _kreuzer);
  }

}