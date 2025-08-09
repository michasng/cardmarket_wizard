import 'package:flutter/material.dart';

class CountControl extends StatelessWidget {
  final int min, max, value;
  final void Function(int value) onChange;
  final double? iconSize;

  const CountControl({
    super.key,
    this.min = 0,
    required this.max,
    required this.value,
    required this.onChange,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: value > min ? () => onChange(value - 1) : null,
          icon: Icon(Icons.remove),
          iconSize: iconSize,
        ),
        Container(
          alignment: Alignment.center,
          width: 40,
          child: Text('$value/$max', style: theme.textTheme.bodyLarge),
        ),
        IconButton(
          onPressed: value < max ? () => onChange(value + 1) : null,
          icon: Icon(Icons.add),
          iconSize: iconSize,
        ),
      ],
    );
  }
}
