import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

class RestartButton extends StatelessWidget {
  const RestartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        final navigator = Navigator.of(context);
        navigator.go(const LoginScreen());
      },
      child: const Text('Try another wants list'),
    );
  }
}
