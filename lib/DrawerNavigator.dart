import 'package:dsagruppen/Gruppe/GruppeRepository.dart';
import 'package:dsagruppen/Held/HeldRepository.dart';
import 'package:dsagruppen/Held/HeldService.dart';
import 'package:dsagruppen/login/AuthService.dart';
import 'package:dsagruppen/login/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'UserScreen.dart';
import 'globals.dart';
import 'theme/ThemeSwitcher.dart';


class DrawerNavigator extends StatelessWidget {
  const DrawerNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/images/Logo_L.svg',
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                        themeNotifier.value == ThemeMode.dark ? Colors.white : Colors.black,
                        BlendMode.srcIn
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: OutlinedText(text: appName, textStyle: Theme.of(context).textTheme.headlineSmall!, strokeColor: themeNotifier.value == ThemeMode.light ? Colors.white : Colors.black))
              ],
            ),
          ),
          ListTile(
            //leading: const Icon(Icons.home_outlined),
            title: ThemeSwitcher(),
          ),
          ListTile(
            //leading: const Icon(Icons.home_outlined),
            title: const Text("Profil"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserScreen(),
              ),
            )
          ),
          ListTile(
            //leading: const Icon(Icons.home_outlined),
              title: const Text("Logout"),
              onTap: () async {
                await getIt<AuthService>().logout();
                getIt<GruppeRepository>().clearGruppen();
                getIt<HeldRepository>().clearHelden();
                navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
              }
          ),
        ],
      ),
    );
  }
}

class OutlinedText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final double strokeWidth;
  Color strokeColor;

  OutlinedText({
    required this.text,
    required this.textStyle,
    this.strokeWidth = 2.0,
    required this.strokeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center, // Zentriert den Text im Stack
      children: <Widget>[
        // Umriss
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // Regulärer Text
        Text(
          text,
          style: textStyle,
        ),
      ],
    );
  }
}
