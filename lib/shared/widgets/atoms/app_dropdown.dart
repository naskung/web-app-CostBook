import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_sizes.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.validator,
  });

  final String label;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSizes.spaceSmall),
        DropdownButtonFormField<T>(
          initialValue: items.containsKey(value) ? value : null,
          isExpanded: true,
          hint: hint == null ? null : Text(hint ?? ''),
          validator: validator,
          onChanged: onChanged,
          items: [
            for (final entry in items.entries)
              DropdownMenuItem<T>(value: entry.key, child: Text(entry.value, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ],
    );
  }
}
