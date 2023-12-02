import 'package:dsagruppen/UserPreferences.dart';
import 'package:flutter/material.dart';

import '../globals.dart';

class ThemeSwitcher extends StatefulWidget {
  @override
  ThemeSwitcherState createState() => ThemeSwitcherState();
}

class ThemeSwitcherState extends State<ThemeSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.wb_sunny,
          color: themeNotifier.value == ThemeMode.dark ? Colors.grey : Colors.orange,
        ),
        Switch(
          value: themeNotifier.value == ThemeMode.dark,
          onChanged: (value) {
            setState(() {
              if(themeNotifier.value == ThemeMode.light){
                themeNotifier.value = ThemeMode.dark;
              } else {
                themeNotifier.value = ThemeMode.light;
              }
              getIt<UserPreferences>().saveTheme(themeNotifier.value == ThemeMode.light);
            });
          },
        ),
        Icon(
          Icons.nights_stay,
          color: themeNotifier.value == ThemeMode.dark ? Colors.white  : Colors.grey,
        ),
      ],
    );
  }
}
