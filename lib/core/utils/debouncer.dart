import 'dart:async';
import 'package:flutter/foundation.dart';

/// Kelas untuk mencegah aksi berulang yang terlalu cepat
/// seperti multiple tap pada tombol
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}


class Throttle {
  final int milliseconds;
  Timer? _timer;
  bool _isThrottled = false;

  Throttle({this.milliseconds = 500});

  void run(VoidCallback action) {
    if (!_isThrottled) {
      action();
      _isThrottled = true;
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _isThrottled = false;
      });
    }
  }

  bool get isThrottled => _isThrottled;

  void dispose() {
    _timer?.cancel();
    _isThrottled = false;
  }
}