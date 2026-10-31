import 'package:flutter/material.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/features/settings/models/product_field_model.dart';
import 'package:costbook/shared/widgets/atoms/app_dropdown.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';

class CustomFieldInput extends StatefulWidget {
  const CustomFieldInput({super.key, required this.field, required this.value, required this.onChanged});

  final ProductFieldModel field;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<CustomFieldInput> createState() => _CustomFieldInputState();
}

class _CustomFieldInputState extends State<CustomFieldInput> {
  late final _controller = TextEditingController(text: _displayText(widget.value));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _displayText(String value) {
    if (widget.field.type != ProductFieldModel.date || value.isEmpty) return value;
    return DateUtil.toDisplayDate(DateUtil.fromApiDate(value));
  }

  String? _validateNumber(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || double.tryParse(text.replaceAll(',', '')) != null) return null;
    return 'validation.number'.tr;
  }

  Future<void> _pickDate() async {
    final initial = widget.value.isEmpty ? DateTime.now() : DateUtil.fromApiDate(widget.value);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    _controller.text = DateUtil.toDisplayDate(picked);
    widget.onChanged(DateUtil.toApiDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    if (field.type == ProductFieldModel.select) {
      return AppDropdown<String>(
        label: field.name,
        hint: 'product.choose_option'.tr,
        value: widget.value.isEmpty ? null : widget.value,
        items: {for (final option in field.options) option: option},
        onChanged: (value) => widget.onChanged(value ?? ''),
      );
    }
    if (field.type == ProductFieldModel.date) {
      return AppTextField(
        label: field.name,
        controller: _controller,
        icon: Icons.calendar_today_outlined,
        readOnly: true,
        onTap: _pickDate,
      );
    }
    final isNumber = field.type == ProductFieldModel.number;
    return AppTextField(
      label: field.name,
      controller: _controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      validator: isNumber ? _validateNumber : null,
      onChanged: (text) => widget.onChanged(text.trim()),
    );
  }
}
