import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class LocationDropdown extends StatelessWidget {
  final String? labelText;
  final Location? value;
  final void Function(Location newValue) onChanged;

  const LocationDropdown({
    super.key,
    this.labelText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: labelText,
      ),
      value: value,
      onChanged: (newValue) => onChanged(newValue!),
      items: [
        for (final location
            in Location.values.sortedBy((location) => location.label))
          DropdownMenuItem(
            value: location,
            child: Text(location.label),
          ),
      ],
    );
  }
}
