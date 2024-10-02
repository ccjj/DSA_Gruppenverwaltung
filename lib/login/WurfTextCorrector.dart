import 'dart:math';

import '../Held/Held.dart';
import '../skills/TalentRepository .dart';
import '../skills/ZauberRepository.dart';

class WurfTextCorrector {


  final TalentRepository trep;
  final ZauberRepository zrep;
  final List<String> heldAttributeNames;

  List<String> skills = [];

  WurfTextCorrector(this.trep, this.zrep, this.heldAttributeNames){
    _prepareSkillNames();
  }

  int? extractModifier(String userInput) {
    // Check for "erschwert um" or "erleichtert um" followed by a number
    RegExp modExp = RegExp(r'(erschwert|erleichtert) um (\d+)');
    RegExpMatch? match = modExp.firstMatch(userInput);

    if (match != null) {
      String type = match.group(1)!;  // "erschwert" oder "erleichtert"
      int value = int.parse(match.group(2)!);  // Zahl extrahieren und in int umwandeln

      // Wenn es "erschwert" ist, die Zahl negativ machen, sonst positiv lassen
      return type == 'erschwert' ? -value : value;
    }

    // Wenn kein Modifikator gefunden wurde, null zurückgeben
    return null;
  }

  String? _getByRegex(String userInput){
    RegExp regExp = RegExp(r'auf (.+?)[ ]*(erschwert|erleichtert|$)');

    Match? match = regExp.firstMatch(userInput);

    if (match != null) {
      return match.group(1); // This prints the first capture group
    }
    return null;
  }

  //TODO regex
  String extractSkillName(String userInput) {
    var regexResult = _getByRegex(userInput);
    if(regexResult != null) return _findClosestSkill(regexResult, 2);

    double threshold = 2;
    List<String> words = userInput.split(' ');  // Die Benutzeranfrage in Wörter aufteilen
    String closestSkill = skills[0];
    double minDistance = double.infinity;

    // Überprüfe alle n-Gramme (ein- und zweigrämmige Kombinationen)
    for (int i = 0; i < words.length; i++) {
      // Ein-Wort-Gramm
      String singleWord = words[i];
      String closestSingleSkill = _findClosestSkill(singleWord, threshold);
      double singleWordDistance = _levenshtein(singleWord, closestSingleSkill) / max(singleWord.length, closestSingleSkill.length).toDouble();

      if (singleWordDistance < minDistance) {
        minDistance = singleWordDistance;
        closestSkill = closestSingleSkill;
      }

      // Zwei-Wort-Gramm
      if (i + 1 < words.length) {
        String twoWords = words[i] + ' ' + words[i + 1];
        String closestTwoWordSkill = _findClosestSkill(twoWords, threshold);
        double twoWordDistance = _levenshtein(twoWords, closestTwoWordSkill) / max(twoWords.length, closestTwoWordSkill.length).toDouble();

        if (twoWordDistance < minDistance) {
          minDistance = twoWordDistance;
          closestSkill = closestTwoWordSkill;
        }
      }
    }
    return closestSkill;
  }
  String capitalizeFirstChar(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  String normalize(String input) {
    input = input.toLowerCase();
    input = input.replaceAll('ß', 'ss').replaceAll('ph', 'f');
    return input;
  }

  String _findClosestSkill(String userSkill, double threshold) {
    userSkill = capitalizeFirstChar(userSkill);
    if(skills.contains(userSkill)){
      return userSkill;
    }
    if(skills.contains(normalize(userSkill))){
      return userSkill;
    }
    String closestSkill = skills[0];
    double minDistance = double.infinity;  // Großer Startwert

    for (String skill in skills) {
      double distance = _levenshtein(userSkill, skill) / max(userSkill.length, skill.length).toDouble();

      // Verwerfe Ergebnisse, die über dem Schwellenwert liegen
      if (distance < minDistance && distance <= threshold) {
        minDistance = distance;
        closestSkill = skill;
      }
    }

    // Rückgabe des Skill-Namens mit der kleinsten Distanz, die den Schwellenwert nicht überschreitet
    return closestSkill;
  }

  void _prepareSkillNames(){
    skills = trep.getTalentsAsStringList();
    skills.addAll(zrep.getZauberAsStringList());
    skills.addAll(Held.getFullNameAttributeMap());
  }

  int _levenshtein(String s1, String s2) {
    int len1 = s1.length;
    int len2 = s2.length;

    List<List<int>> dp = List.generate(len1 + 1, (_) => List<int>.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) {
      for (int j = 0; j <= len2; j++) {
        if (i == 0) {
          dp[i][j] = j; // Alle Buchstaben von s2 einfügen
        } else if (j == 0) {
          dp[i][j] = i; // Alle Buchstaben von s1 löschen
        } else if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1]; // Gleiche Buchstaben, keine Änderung
        } else {
          dp[i][j] = 1 + [
            dp[i - 1][j],     // Löschen
            dp[i][j - 1],     // Einfügen
            dp[i - 1][j - 1]  // Ersetzen
          ].reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return dp[len1][len2];
  }

}