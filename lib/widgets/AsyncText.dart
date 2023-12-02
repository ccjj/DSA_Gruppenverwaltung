import 'package:flutter/material.dart';

class AsyncText extends StatelessWidget {
  final Future<String?> Function() callback;
  final TextStyle? style;
  final String? prefixText;
  AsyncText({super.key, required this.callback, this.prefixText, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: callback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while waiting for data
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(child: CircularProgressIndicator()),
            ],
          );
        } else if (snapshot.hasError) {
          // Handle errors if any
          return Text('Error: ${snapshot.error}');
        } else {
          // Display the data
          return Text(snapshot.data ?? '?', style: style ?? TextStyle());
        }
      },
    );
  }
}
