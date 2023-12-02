import 'dart:async';
import 'package:flutter/material.dart';

class PlusMinusButton extends StatelessWidget {
  final String title;
  final ValueNotifier<int> value;
  final int maxValue;
  final Widget leading;
  final Function(int) onValueChanged;

  PlusMinusButton({
    super.key,
    required this.title,
    required int value,
    required this.maxValue,
    required this.onValueChanged,
    required this.leading,
  }) : value = ValueNotifier<int>(value);

  void _debouncedValueChange(int newValue) {
    Timer? _debounce;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      onValueChanged(newValue);
    });
  }

  void _updateValue(int change) {
    value.value = (value.value + change);
    _debouncedValueChange(value.value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: leading,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () => _updateValue(-1),
              ),
              ValueListenableBuilder<int>(
                valueListenable: value,
                builder: (context, val, _) {
                  return Text('$val / $maxValue', style: Theme.of(context).textTheme.titleMedium);
                },
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () => _updateValue(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
