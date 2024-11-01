
import 'package:dsagruppen/widgets/MainScaffold.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'Gruppe/Gruppe.dart';
import 'InitiativeTracker.dart';
import 'chat/BottomBar/ChatBottomBar.dart';
import 'globals.dart';

class IniTrackerPage extends StatefulWidget {
  Gruppe gruppe;

  IniTrackerPage({super.key, required this.gruppe});

  @override
  State<IniTrackerPage> createState() => _IniTrackerPageState();
}

class _IniTrackerPageState extends State<IniTrackerPage> {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
        title: const Text("Meisterseite"),
    
    bnb: ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET) ? ChatBottomBar(
    gruppeId: widget.gruppe.uuid,
    stream: messageController.stream,
    ) : null,
    body: InitiativeTracker(widget.gruppe.helden)
    );
  }
}