
import 'package:flutter/material.dart';

import '../widgets/ConditionalParentWidget.dart';

class CardWithTitle extends StatelessWidget {
  const CardWithTitle({
    super.key,
    required this.child,
    required this.title
  });

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Text(title, style: Theme.of(context).textTheme.titleLarge),
                )
            ),
            child
          ],
        ),
      ),
    );
  }
}
