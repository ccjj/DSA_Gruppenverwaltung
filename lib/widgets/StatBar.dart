import 'package:flutter/material.dart';

class StatBar extends StatelessWidget {
  final int value;
  final int maxValue;
  final String label;
  final Color color;

  StatBar({required this.value, required this.maxValue, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    double fraction = value / maxValue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // Adjust the radius for desired roundness
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: Colors.grey,
                color: color,
                minHeight: 12,
              ),
            ),
            Text(
              "$value/$maxValue",
              style: TextStyle(color: Colors.black),
            ),
          ],
        )

      ],
    );
  }
}
