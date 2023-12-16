import 'dart:async';
import 'package:flutter/material.dart';

class PlusMinusButton extends StatefulWidget {
  final String title;
  final ValueNotifier<int> value;
  final int? maxValue;
  final Widget leading;
  final Function(int) onValueChanged;
  final bool enabled;

  PlusMinusButton({
    super.key,
    required this.title,
    required int value,
    required this.maxValue,
    required this.onValueChanged,
    required this.leading,
    this.enabled = true
  }) : value = ValueNotifier<int>(value);

  @override
  State<PlusMinusButton> createState() => _PlusMinusButtonState();
}

class _PlusMinusButtonState extends State<PlusMinusButton> {
  Timer? _debounce;

  void _debouncedValueChange(int newValue) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      widget.onValueChanged(newValue);
    });
  }


  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _updateValue(int change) {
    widget.value.value = (widget.value.value + change);
    _debouncedValueChange(widget.value.value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.title),
          leading: widget.leading,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: widget.enabled,
                child: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _updateValue(-1),
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: widget.value,
                builder: (context, val, _) {
                  return Text(widget.maxValue != null ? '$val / ${widget.maxValue}' : val.toString(), style: Theme.of(context).textTheme.titleMedium);
                },
              ),
              Visibility(
                visible: widget.enabled,
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _updateValue(1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
