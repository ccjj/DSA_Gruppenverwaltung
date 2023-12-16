import 'package:flutter/material.dart';

import '../services/MoneyConversion.dart';

class CurrencyConverter extends StatefulWidget {
  int initialKreuzer;

  CurrencyConverter({super.key, required this.initialKreuzer});

  @override
  CurrencyConverterState createState() => CurrencyConverterState();
}

class CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _dukatenController = TextEditingController();
  final TextEditingController _silberController = TextEditingController();
  final TextEditingController _hellerController = TextEditingController();
  final TextEditingController _kreuzerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _kreuzerController.text = widget.initialKreuzer.toString();
    _convertAndDisplay(widget.initialKreuzer);
  }

  void _convertCurrency() {
    int totalKreuzer = MoneyConversion.calcKreuzerByStr(_dukatenController.text, _silberController.text, _hellerController.text, _kreuzerController.text);
    _convertAndDisplay(totalKreuzer);
  }

  void _convertAndDisplay(int totalKreuzer) {
    int dukaten = totalKreuzer ~/ 1000;
    int remainingAfterDukaten = totalKreuzer % 1000;

    int silber = remainingAfterDukaten ~/ 100;
    int remainingAfterSilber = remainingAfterDukaten % 100;

    int heller = remainingAfterSilber ~/ 10;
    int remainingKreuzer = remainingAfterSilber % 10;

    _dukatenController.text = dukaten.toString();
    _silberController.text = silber.toString();
    _hellerController.text = heller.toString();
    _kreuzerController.text = remainingKreuzer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTextField(_dukatenController, 'Dukaten', Icons.monetization_on),
            SizedBox(height: 10),
            _buildTextField(_silberController, 'Silber', Icons.attach_money ),
            SizedBox(height: 10),
            _buildTextField(_hellerController, 'Heller', Icons.money_off_csred),
            SizedBox(height: 10),
            _buildTextField(_kreuzerController, 'Kreuzer', Icons.money),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertCurrency,
              child: Text('Konvertieren'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text('Abbrechen'),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(MoneyConversion.calcKreuzerByStr(_dukatenController.text, _silberController.text, _hellerController.text, _kreuzerController.text)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: TextInputType.number,
    );
  }
}
