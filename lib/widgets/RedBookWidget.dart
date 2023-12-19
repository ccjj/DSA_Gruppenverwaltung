import 'package:flutter/material.dart';

class RedBookWidget extends StatelessWidget {
  final String title;
  const RedBookWidget({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Adjust the size as needed
      height: 150, // Adjust the size as needed
      decoration: BoxDecoration(
        color: const Color.fromRGBO(144, 10, 2, 1),
        borderRadius: BorderRadius.circular(10), // Rounded corners for the book
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(2, 2), // Shadow position
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color.fromRGBO(218, 165, 32, 1),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
