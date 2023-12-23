import 'package:flutter/material.dart';

import '../globals.dart';

class ExpandArrowContainer extends StatelessWidget {
  final bool isExpanded;

  const ExpandArrowContainer({required this.isExpanded, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      color: themeNotifier.value == ThemeMode.light ?  Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
      alignment: Alignment.center,
      child: Icon(
        isExpanded ? Icons.expand_more : Icons.expand_less,
        color: Colors.white,
        size: 12,
      ),
    );
  }
}