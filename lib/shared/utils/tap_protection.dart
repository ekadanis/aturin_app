import 'package:aturin_app/shared/utils/debouncer.dart';
import 'package:flutter/material.dart';

/// Mixin untuk melindungi dari multiple tap pada widget
mixin TapProtectionMixin<T extends StatefulWidget> on State<T> {
  final _navigationThrottle = Throttle(milliseconds: 800);
  final _buttonThrottle = Throttle(milliseconds: 500);
  void safeNavigate(Function() navigationAction) {
    _navigationThrottle.run(navigationAction);
  }

  void safeOnTap(Function() onTapAction) {
    _buttonThrottle.run(onTapAction);
  }
  
  @override
  void dispose() {
    _navigationThrottle.dispose();
    _buttonThrottle.dispose();
    super.dispose();
  }
}

extension TapProtectionExtension on Widget {
  Widget withTapThrottle({
    required Function() onTap, 
    int milliseconds = 500,
  }) {
    final throttle = Throttle(milliseconds: milliseconds);

    return GestureDetector(
      onTap: () => throttle.run(onTap),
      child: this,
    );
  }
}