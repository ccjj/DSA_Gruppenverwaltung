import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Function onTap;

  const AnimatedIconButton({super.key, required this.icon, required this.onTap});

  @override
  AnimatedIconButtonState createState() => AnimatedIconButtonState();
}

class AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onTap();
      },
      child: Animate(
        child: Icon(widget.icon).animate(autoPlay: false, controller: _controller)
          .shake(duration: 500.ms, rotation: 0.2, curve: Curves.easeInOut)
      ),
    );
  }
}
