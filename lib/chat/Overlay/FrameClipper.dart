import 'package:flutter/material.dart';

class FrameClipper extends CustomClipper<Path> {
  final double borderWidth;

  FrameClipper({this.borderWidth = 5.0});

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)) // Outer rectangle (full container)
      ..addRect(Rect.fromLTWH(borderWidth, borderWidth, size.width - 2 * borderWidth, size.height - 2 * borderWidth)) // Inner rectangle (cut-out)
      ..fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}