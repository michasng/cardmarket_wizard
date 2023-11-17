import 'package:cardmarket_wizard/login_to_cardmarket.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Cardmarket Wizard'),
      ),
      body: const Center(
        child: LoginToCardmarket(),
      ),
    );
  }
}
