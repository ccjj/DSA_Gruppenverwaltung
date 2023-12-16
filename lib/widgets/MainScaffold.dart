import 'package:flutter/material.dart';

import 'DrawerNavigator.dart';

class MainScaffold extends StatelessWidget {
  Widget body;
  Widget title;
  Widget? fab;
  Widget? bnb;
  Widget? bs;
  MainScaffold({required this.body, required this.title, this.fab, this.bnb, this.bs, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      endDrawer: const DrawerNavigator(),
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: bnb,
      bottomSheet: bs
    );
  }
}
