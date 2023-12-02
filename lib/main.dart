import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dsagruppen/Gruppe/GroupService.dart';
import 'package:dsagruppen/Held/HeldAmplifyService.dart';
import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/User/UserAmplifyService.dart';
import 'package:dsagruppen/login/AuthService.dart';
import 'package:dsagruppen/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'Gruppe/GroupAmplifyService.dart';
import 'Gruppe/GruppeRepository.dart';
import 'Held/HeldRepository.dart';
import 'HeldGroupCoordinator.dart';
import 'User/UserRepository.dart';
import 'UserPreferences.dart';
import 'amplifyconfiguration.dart';
import 'globals.dart';
import 'login/LoginPage.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerSingleton<UserRepository>(UserRepository());
  getIt.registerSingleton<UserAmplifyService>(UserAmplifyService());
  getIt.registerSingleton<HeldRepository>(HeldRepository());
  getIt.registerSingleton<HeldAmplifyService>(HeldAmplifyService(
    getIt<HeldRepository>()
  ));
  getIt.registerSingleton<GruppeRepository>(GruppeRepository());
  getIt.registerSingleton<HeldService>(HeldService(
      getIt<HeldRepository>(),
      getIt<HeldAmplifyService>()
  ));
  getIt.registerSingleton<GroupAmplifyService>(GroupAmplifyService());
  getIt.registerSingleton<GroupService>(GroupService(
    getIt<GruppeRepository>(),
    getIt<GroupAmplifyService>()
  ));
  getIt.registerSingleton<HeldGroupCoordinator>(HeldGroupCoordinator(
      getIt<GroupService>(),
      getIt<HeldRepository>()
  ));



  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<UserPreferences>(UserPreferences());
  getIt<UserPreferences>().getTheme().then((isLightTheme) => themeNotifier.value = (isLightTheme ?? true) ? ThemeMode.light : ThemeMode.dark);
  //getIt<UserRepository>().addUser(cu);
  /*
  getIt<GruppenRepository>().addGruppe(Gruppe(helden: [], erstelltVon: cu, name: "Omars Ignifaxius-Grenadiere"));
  getIt<GruppenRepository>().addGruppe(Gruppe(helden: [], erstelltVon: cu, name: "Rohaldors Sturmtruppen"));
  getIt<GruppenRepository>().addGruppe(Gruppe(helden: [], erstelltVon: cu, name: "Xorloschs Kuschelgrabscher"));
   */
  configureAmplify();

  runApp(MyApp());
}

void configureAmplify() async {
  final AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
  final AmplifyAPI apiPlugin = AmplifyAPI();

  try {
    await Amplify.addPlugins([authPlugin, apiPlugin]);
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print("An error occurred setting up Amplify: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'DSA Gruppenverwaltung',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          navigatorKey: navigatorKey,
          home: LoginPage(),
          builder: EasyLoading.init(),
          debugShowCheckedModeBanner: false,
        );
      }
    );
  }
}
