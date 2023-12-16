import 'package:flutter/material.dart';

class AsyncText extends StatelessWidget {
  final Future<String?> Function() callback;
  final TextStyle? style;
  final String? prefixText;
  final bool showSpinner;
  const AsyncText({super.key, required this.callback, this.prefixText, this.style, this.showSpinner = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: callback(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          var widget = showSpinner ?
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: CircularProgressIndicator()),
            ],
          ) : const SizedBox.shrink();
          return widget;
        } else if (snapshot.hasError) {
          // Handle errors if any
          return Text('Error: ${snapshot.error}');
        } else {
          // Display the data
          return Text(snapshot.data ?? '?', style: style ?? const TextStyle());
        }
      },
    );
  }
}
