List<Rasse> Rassen = [
Rasse("Mittelländer", {"mu": 0, "kl": 0, "in": 0, "ch": 0, "ff": 0, "ge": 0, "ko": 0, "kk": 0}),
Rasse("Nivese", {"mu": 0, "kl": 0, "in": 1, "ch": 0, "ff": 0, "ge": 0, "ko": 1, "kk": 0}),
Rasse("Elf", {"mu": 0, "kl": 0, "in": 0, "ch": 2, "ff": 2, "ge": 0, "ko": -2, "kk": -2}),
Rasse("Halbelf", {"mu": 0, "kl": 0, "in": 0, "ch": 1, "ff": 1, "ge": 0, "ko": 0, "kk": 0}),
Rasse("Zwerg", {"mu": 0, "kl": 0, "in": 0, "ch": -2, "ff": 0, "ge": 0, "ko": 2, "kk": 2}),
Rasse("Achaz", {"mu": -1, "kl": 0, "in": 0, "ch": -2, "ff": 0, "ge": 0, "ko": 2, "kk": 1}),
Rasse("Goblin", {"mu": -1, "kl": 0, "in": -1, "ch": -2, "ff": 1, "ge": 1, "ko": -1, "kk": -1}),
Rasse("Ork", {"mu": 0, "kl": -1, "in": -1, "ch": -2, "ff": 0, "ge": 0, "ko": 2, "kk": 2}),
Rasse("Oger", {"mu": -1, "kl": -1, "in": -1, "ch": -1, "ff": -1, "ge": -1, "ko": 3, "kk": 3}),
Rasse("Troll", {"mu": -2, "kl": -2, "in": -2, "ch": -2, "ff": -2, "ge": -2, "ko": 5, "kk": 5}),
Rasse("Firnelfen", {"mu": 0, "kl": 0, "in": 0, "ch": 2, "ff": 2, "ge": 0, "ko": -2, "kk": -2}),
Rasse("Auelfen", {"mu": 0, "kl": 0, "in": 0, "ch": 2, "ff": 2, "ge": 0, "ko": -2, "kk": -2}),
Rasse("Waldelfen", {"mu": 0, "kl": 0, "in": 0, "ch": 2, "ff": 2, "ge": 0, "ko": -2, "kk": -2}),
Rasse("Steppenelfen", {"mu": 0, "kl": 0, "in": 0, "ch": 2, "ff": 2, "ge": 0, "ko": -2, "kk": -2}),
Rasse("Thorwaler", {"mu": 1, "kl": 0, "in": 0, "ch": 0, "ff": 0, "ge": 0, "ko": 1, "kk": 1}),
Rasse("Tulamide", {"mu": 0, "kl": 0, "in": 0, "ch": 1, "ff": 0, "ge": 0, "ko": 0, "kk": -1}),
  Rasse("Fjarninger", {"mu": 0, "kl": 0, "in": -1, "ch": 0, "ff": 0, "ge": 0, "ko": 2, "kk": 1}),
  Rasse("Svellttaler", {"mu": 0, "kl": 1, "in": 0, "ch": 0, "ff": 0, "ge": -1, "ko": 0, "kk": 0}),
  Rasse("Norbarden", {"mu": 0, "kl": 0, "in": 1, "ch": 0, "ff": 0, "ge": 0, "ko": 0, "kk": -1}),
  Rasse("Gjalskerländer", {"mu": 1, "kl": 0, "in": 0, "ch": -1, "ff": 0, "ge": 0, "ko": 1, "kk": 0}),
  Rasse("Utulus", {"mu": -1, "kl": 0, "in": 0, "ch": 0, "ff": 0, "ge": 1, "ko": 0, "kk": 0}),
  Rasse("Zyklopen", {"mu": 0, "kl": -2, "in": -2, "ch": -2, "ff": -2, "ge": -2, "ko": 4, "kk": 4}),
];



class Rasse {
  String name;
  Map<String, int> eigenschaftsModifikationen;

  Rasse(this.name, this.eigenschaftsModifikationen);
}
