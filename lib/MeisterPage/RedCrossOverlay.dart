import 'package:flutter/material.dart';

class RedCrossOverlay extends StatelessWidget {
  final Widget child;
  final bool showOverlay;

  const RedCrossOverlay({required this.child, this.showOverlay = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showOverlay)
          Positioned.fill(
            child: Container(
              color: Colors.red.withOpacity(0.5),
              child: const Center(
                child: Icon(
                  Icons.cancel,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
