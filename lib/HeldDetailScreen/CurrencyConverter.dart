import 'package:flutter/material.dart';

import '../services/MoneyConversion.dart';
import '../widgets/PlusMinusButton.dart';

class CurrencyConverter extends StatefulWidget {
  int initialKreuzer;

  CurrencyConverter({super.key, required this.initialKreuzer});

  @override
  CurrencyConverterState createState() => CurrencyConverterState();
}

class CurrencyConverterState extends State<CurrencyConverter> {

  final ValueNotifier<int> _dukatenValue = ValueNotifier<int>(0);
  final ValueNotifier<int> _silberValue = ValueNotifier<int>(0);
  final ValueNotifier<int> _hellerValue = ValueNotifier<int>(0);
  final ValueNotifier<int> _kreuzerValue = ValueNotifier<int>(0);


  @override
  void initState() {
    super.initState();
    _kreuzerValue.value = widget.initialKreuzer;
    _convertAndDisplay(widget.initialKreuzer);
  }

  void _convertCurrency() {
    int totalKreuzer = MoneyConversion.calcKreuzer(_dukatenValue.value, _silberValue.value, _hellerValue.value, _kreuzerValue.value);
    _convertAndDisplay(totalKreuzer);
  }

  void _convertAndDisplay(int totalKreuzer) {
    int dukaten = totalKreuzer ~/ 1000;
    int remainingAfterDukaten = totalKreuzer % 1000;

    int silber = remainingAfterDukaten ~/ 100;
    int remainingAfterSilber = remainingAfterDukaten % 100;

    int heller = remainingAfterSilber ~/ 10;
    int remainingKreuzer = remainingAfterSilber % 10;

    _dukatenValue.value = dukaten;
    _silberValue.value = silber;
    _hellerValue.value = heller;
    _kreuzerValue.value = remainingKreuzer;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlusMinusButton(
              title: 'Dukaten',
              value: _dukatenValue,
              maxValue: 100, // Example max value
              leading: Icon(Icons.monetization_on),
              onValueChanged: (newValue) {
                _handleCurrencyChange('Dukaten', newValue);
              },
              enabled: true,
              shouldDebounce: false,
            ),
            SizedBox(height: 10),
            PlusMinusButton(
              title: 'Silber',
              value: _silberValue,
              leading: Icon(Icons.attach_money),
              onValueChanged: (newValue) {
                _handleCurrencyChange('Silber', newValue);
              },
              enabled: true,
              shouldDebounce: false,
            ),
            SizedBox(height: 10),
            PlusMinusButton(
              title: 'Heller',
              value: _hellerValue,
              leading: Icon(Icons.money_off_csred),
              onValueChanged: (newValue) {
                _handleCurrencyChange('Heller', newValue);
              },
              enabled: true,
              shouldDebounce: false,
            ),
            SizedBox(height: 10),
            PlusMinusButton(
              title: 'Kreuzer',
              value: _kreuzerValue,
              leading: Icon(Icons.money),
              onValueChanged: (newValue) {
                _handleCurrencyChange('Kreuzer', newValue);
              },
              enabled: true,
              shouldDebounce: false,
            ),
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
                  onPressed: () => Navigator.of(context).pop(MoneyConversion.calcKreuzer(_dukatenValue.value, _silberValue.value, _hellerValue.value, _kreuzerValue.value)),
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

  void _handleCurrencyChange(String currencyType, int newValue) {
    print("uod");
    switch (currencyType) {
      case 'Dukaten':
        _dukatenValue.value = newValue;
        break;
      case 'Silber':
        _silberValue.value = newValue;
        break;
      case 'Heller':
        _hellerValue.value = newValue;
        break;
      case 'Kreuzer':
        _kreuzerValue.value = newValue;
        break;
    }

    int totalKreuzer = MoneyConversion.calcKreuzer(_dukatenValue.value, _silberValue.value, _hellerValue.value, _kreuzerValue.value);
    _convertAndDisplay(totalKreuzer);
  }


}
