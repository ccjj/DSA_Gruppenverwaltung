import 'package:flutter/material.dart';

class ConditionalParentWidget extends StatelessWidget {
  const ConditionalParentWidget({
    super.key,
    required this.condition,
    required this.child,
    required this.parentBuilder,
  });

  final Widget child;
  final bool condition;
  final Widget Function(Widget child) parentBuilder;

  @override
  Widget build(BuildContext context) {
    return condition ? parentBuilder(child) : child;
  }
}