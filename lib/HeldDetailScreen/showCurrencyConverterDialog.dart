
import 'package:flutter/material.dart';

import '../Held/Held.dart';
import 'CurrencyConverter.dart';

Future<void> showCurrencyConverterDialog(
    BuildContext context, Held held, int Function(int newKreuzer) callback) async {
  await showDialog<int?>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CurrencyConverter(
              initialKreuzer: held.kreuzer.value,
            ),
          ),
        ),
      );
    },
  ).then((kreuzer) {
    if (kreuzer != null) {
      callback(kreuzer);
    }
  });
}
