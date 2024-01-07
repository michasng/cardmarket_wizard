import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:flutter/material.dart';

class LocationDropdown extends StatelessWidget {
  final Location? value;
  final void Function(Location? newValue) onChanged;

  const LocationDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: DropdownButtonFormField(
        value: value,
        onChanged: onChanged,
        items: [
          for (final location in Location.values)
            DropdownMenuItem(
              value: location,
              child: Text(location.name),
            ),
        ],
      ),
    );
  }
}
