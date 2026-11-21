import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/validator_util.dart';
import 'package:costbook/shared/widgets/atoms/app_text_field.dart';

class DocumentCustomerFields extends StatelessWidget {
  const DocumentCustomerFields({
    super.key,
    required this.nameController,
    required this.taxIdController,
    required this.branchController,
    required this.addressController,
    required this.dateFields,
    this.isNameRequired = true,
  });

  final TextEditingController nameController;
  final TextEditingController taxIdController;
  final TextEditingController branchController;
  final TextEditingController addressController;
  final List<Widget> dateFields;
  final bool isNameRequired;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
        final halfWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - AppSizes.spaceMedium) / 2;
        return Wrap(
          spacing: AppSizes.spaceMedium,
          runSpacing: AppSizes.spaceMedium,
          children: [
            SizedBox(
              width: halfWidth,
              child: AppTextField(
                label: 'invoice.customer_name'.tr,
                controller: nameController,
                validator: isNameRequired ? ValidatorUtil.required : null,
              ),
            ),
            for (final field in dateFields) SizedBox(width: halfWidth, child: field),
            SizedBox(
              width: halfWidth,
              child: AppTextField(
                label: 'invoice.customer_tax_id'.tr,
                hint: 'settings.tax_id_hint'.tr,
                controller: taxIdController,
                keyboardType: TextInputType.number,
                validator: ValidatorUtil.taxId,
              ),
            ),
            SizedBox(
              width: halfWidth,
              child: AppTextField(
                label: 'invoice.customer_branch'.tr,
                hint: 'settings.branch_hint'.tr,
                controller: branchController,
              ),
            ),
            AppTextField(label: 'invoice.customer_address'.tr, controller: addressController, maxLines: 2),
          ],
        );
      },
    );
  }
}
