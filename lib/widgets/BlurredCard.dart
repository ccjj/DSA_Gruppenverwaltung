import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredCard extends StatelessWidget {
  final double blurAmount;
  final Widget child;

  const BlurredCard({super.key, required this.child, this.blurAmount = 8.0});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRect(
        child: Stack(
          children: [
            IgnorePointer( // Make the child non-interactive
              child: child,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
