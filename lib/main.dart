import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dsagruppen/Gruppe/GroupService.dart';
import 'package:dsagruppen/Held/HeldAmplifyService.dart';
import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/User/UserAmplifyService.dart';
import 'package:dsagruppen/actions/ActionStack.dart';
import 'package:dsagruppen/login/AuthService.dart';
import 'package:dsagruppen/model/Item.dart';
import 'package:dsagruppen/rules/RollManager.dart';
import 'package:dsagruppen/skills/TalentRepository%20.dart';
import 'package:dsagruppen/skills/ZauberRepository.dart';
import 'package:dsagruppen/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:responsive_framework/breakpoint.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';

import '../Held/Held.dart';
import 'GroupDetailsScreen.dart';
import 'Gruppe/GroupAmplifyService.dart';
import 'Gruppe/Gruppe.dart';
import 'Gruppe/GruppeRepository.dart';
import 'Held/HeldRepository.dart';
import 'HeldGroupCoordinator.dart';
import 'Note/NoteAmplifyService.dart';
import 'User/User.dart';
import 'User/UserRepository.dart';
import 'UserPreferences.dart';
import 'amplifyconfiguration.dart';
import 'chat/ChatMessageRepository.dart';
import 'chat/MessageAmplifyService.dart';
import 'chat/PersonalChatMessageRepository.dart';
import 'globals.dart';
import 'io/PdfFileRepository.dart';
import 'login/LoginPage.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.initFlutter();
  getIt.registerSingleton<UserRepository>(UserRepository());
  getIt.registerSingleton<TalentRepository>(TalentRepository('assets/data/talents.json'));
  getIt.registerSingleton<ZauberRepository>(ZauberRepository('assets/data/spells.json'));
  getIt.registerLazySingleton<RollManager>(() => RollManager());
  getIt.registerLazySingleton<PersonalChatMessageRepository>(() => PersonalChatMessageRepository());
  //getIt.registerLazySingleton<ChatOverlay>(() => ChatOverlay(messageStream: messageController.stream, isVisible: isChatVisible, gruppeId: ""));
  getIt.registerLazySingleton<MessageAmplifyService>(() => MessageAmplifyService());
  getIt.registerLazySingleton<PdfRepository>(() => PdfRepository());
  await getIt<ZauberRepository>().loadZaubers();
  await getIt<TalentRepository>().loadTalents();
  getIt.registerSingleton<ActionStack>(ActionStack());
  getIt.registerSingleton<NoteAmplifyService>(NoteAmplifyService());
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
  getIt.registerSingleton<ChatMessageRepository>(ChatMessageRepository(messageController));
  getIt.registerSingleton<HeldGroupCoordinator>(HeldGroupCoordinator(
      getIt<GroupService>(),
      getIt<HeldRepository>()
  ));
  if(isTest){
    cu = User(name: 'bob', email: 'Bob@bob.de');
    getIt<GruppeRepository>().addGruppe(Gruppe(name: "Omars Ignifaxius-Grenadiere"));
    getIt<GruppeRepository>().addGruppe(Gruppe(name: "Rohaldors Sturmtruppen"));
    getIt<GruppeRepository>().addGruppe(Gruppe(name: "Xorloschs Kuschelgrabscher"));
    getIt<HeldRepository>().addHeld(Held(gruppeId: '123', name: "asd", asp: ValueNotifier(1), ap: 3, at: 1, pa: 1, au: ValueNotifier(1),
    ausbildung: "keine", baseIni: 1, ch: 1, ff: 1, kk: 1, fk: 1, ge: 1, geburtstag: "l", gs: 1, heldNummer: "1234", ini: 2, intu: 3, ke: 1,
      kl: 1, ko: 1, kreuzer: ValueNotifier(1), kultur: "d", maxKe: 1, mr: 1, owner: cu.uuid, mu: 1, so: 1, ws: 1, wunden: 1, rasse: "dd", lp: ValueNotifier(1),
      maxAsp: ValueNotifier(1), maxAu: ValueNotifier(1), maxLp: ValueNotifier(1), talents: {}, notes: {}, sf: [], vorteile: [], zauber: {},
      items: [
        Item(name: "buch", anzahl: 2),
        Item(name: "mantel", anzahl: 1),

      ]
    ));
  }
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<UserPreferences>(UserPreferences());
  getIt<UserPreferences>().getTheme().then((isLightTheme) => themeNotifier.value = (isLightTheme ?? true) ? ThemeMode.light : ThemeMode.dark);
  getIt<UserPreferences>().getShowAusdauer().then((tshowAusdauer) => showAusdauer.value = (tshowAusdauer ?? true) ? true : false);
  //getIt<UserRepository>().addUser(cu);


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
          //home: isTest ? GroupDetailsScreen(gruppe: getIt<GruppeRepository>().getAllGruppen()[0]) : LoginPage(),//LoginPage(),//
          home: isTest ? GroupDetailsScreen(gruppe: getIt<GruppeRepository>().getAllGruppen()[0]) : LoginPage(),//LoginPage(),//
          builder: (context, child) {
            child = EasyLoading.init()(context,child);
          child = ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          );
          return child;
        },
          debugShowCheckedModeBanner: false,
        );
      }
    );
  }
}
