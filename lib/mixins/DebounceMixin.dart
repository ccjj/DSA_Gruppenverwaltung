import 'dart:async';

import 'package:flutter/foundation.dart';

mixin DebounceMixin {
  Timer? _debounce;

  void debounce(VoidCallback action, Duration duration) {
    _debounce?.cancel();

    _debounce = Timer(duration, action);
  }


  void disposeDebounce() {
    _debounce?.cancel();
  }
}
