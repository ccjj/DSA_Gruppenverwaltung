import 'dart:async';
import 'package:flutter/gestures.dart'; // Import for PointerScrollEvent
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PlusMinusButton extends StatefulWidget {
  final String title;
  final ValueNotifier<int> value;
  final int? maxValue;
  final Widget leading;
  final Function(int) onValueChanged;

  final bool isRow;
  final bool enabled;
  final bool shouldDebounce;

  PlusMinusButton({
    super.key,
    required this.title,
    required this.value,
    this.maxValue,
    required this.onValueChanged,
    required this.leading,
    this.isRow = false,
    this.enabled = true,
    this.shouldDebounce = true,
  });

  @override
  State<PlusMinusButton> createState() => _PlusMinusButtonState();
}

class _PlusMinusButtonState extends State<PlusMinusButton> {
  Timer? _debounce;

  void _debouncedValueChange(int newValue) {
    if (!widget.shouldDebounce) {
      widget.onValueChanged(newValue);
      return;
    }
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
    int newValue = widget.value.value + change;

    widget.value.value = newValue;
    _debouncedValueChange(newValue);
  }

  // Method to handle scroll events
  void _handleScroll(PointerScrollEvent event) {
    if (!widget.enabled) return;

    if (event.scrollDelta.dy > 0) {
      // Scrolling down
      _updateValue(-1);
    } else if (event.scrollDelta.dy < 0) {
      // Scrolling up
      _updateValue(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) {
          _handleScroll(signal);
        }
      },
      child: ResponsiveRowColumn(
        rowMainAxisAlignment: MainAxisAlignment.start,
        rowMainAxisSize: MainAxisSize.min,
        columnMainAxisAlignment: MainAxisAlignment.start,
        columnMainAxisSize: MainAxisSize.min,
        columnCrossAxisAlignment: CrossAxisAlignment.start,
        layout: widget.isRow
            ? ResponsiveRowColumnType.ROW
            : ResponsiveRowColumnType.COLUMN,
        rowSpacing: 0,
        columnSpacing: 0,
        children: [
          ResponsiveRowColumnItem(
            rowFit: FlexFit.loose,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.leading,
                Text(widget.title),
              ],
            ),
          ),
          ResponsiveRowColumnItem(
            child: Padding(
              padding: EdgeInsets.only(left: widget.isRow ? 0 : 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                      return Text(
                        widget.maxValue != null
                            ? '$val / ${widget.maxValue}'
                            : val.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      );
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
          ),
        ],
      ),
    );
  }
}
