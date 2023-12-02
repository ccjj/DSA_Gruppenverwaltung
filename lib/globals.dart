import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'User/User.dart';

GetIt getIt = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late User cu;
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
const appName = "DSA Gruppenverwaltung";