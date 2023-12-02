import 'package:flutter/material.dart';

final ThemeData baseTheme = ThemeData(
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 1,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
);

final ThemeData lightTheme = ThemeData.light().copyWith(
  cardTheme: baseTheme.cardTheme,
  floatingActionButtonTheme: baseTheme.floatingActionButtonTheme
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  cardTheme: baseTheme.cardTheme,
  floatingActionButtonTheme: baseTheme.floatingActionButtonTheme
);
