import 'package:flutter/material.dart';

extension NavigatorStateGo on NavigatorState {
  Future<T?> go<T extends Object?>(Widget screen) {
    return pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }
}
