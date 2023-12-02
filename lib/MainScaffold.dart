import 'package:flutter/material.dart';

import 'DrawerNavigator.dart';

class MainScaffold extends StatelessWidget {
  Widget body;
  String title;
  Widget? fab;
  MainScaffold({required this.body, required this.title, this.fab, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),

      ),
      endDrawer: const DrawerNavigator(),
      body: body,
      floatingActionButton: fab,
    );
  }
}
