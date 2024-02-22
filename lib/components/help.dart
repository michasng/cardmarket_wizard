import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class Help extends StatelessWidget {
  final Widget child;
  final String message;

  const Help({
    super.key,
    required this.child,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: child),
        Tooltip(
          message: message,
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          child: const Icon(Icons.help),
        ),
      ].separated(const Gap()),
    );
  }
}
