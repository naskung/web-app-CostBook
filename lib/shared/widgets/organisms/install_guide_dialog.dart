import 'package:flutter/material.dart';

import 'package:costbook/core/constants/install_guide.dart';
import 'package:costbook/core/helpers/web_app_helper.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/install_util.dart';
import 'package:costbook/shared/widgets/organisms/app_dialog.dart';

class InstallGuideDialog extends StatelessWidget {
  const InstallGuideDialog({super.key, required this.guide});

  final InstallGuide guide;

  // กด "เพิ่มไว้ที่หน้าจอ": browser ติดตั้งให้ได้ (Chrome / Edge / Android) → เปิดหน้าต่างติดตั้งเลย
  // ติดตั้งให้ไม่ได้ (iPhone / Safari / Firefox ฯลฯ) → บอกวิธีของเครื่องนี้ / true = ผู้ใช้กดติดตั้งแล้ว
  static Future<bool> start(BuildContext context) async {
    if (WebAppHelper.canPrompt) return WebAppHelper.prompt();
    await showDialog<void>(context: context, builder: (_) => InstallGuideDialog(guide: WebAppHelper.guide));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppDialog(
      title: 'install.title'.tr,
      icon: Icons.install_mobile_outlined,
      closeLabel: 'common.close'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('install.this_device'.tr, style: textTheme.bodySmall),
          const SizedBox(height: AppSizes.spaceXSmall),
          _GuideSteps(guide: guide),
          const SizedBox(height: AppSizes.spaceMedium),
          Text('install.https_note'.tr, style: textTheme.bodySmall),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: AppSizes.spaceSmall),
            title: Text('install.other_devices'.tr, style: textTheme.titleSmall),
            children: [
              for (final other in InstallUtil.otherGuides(guide))
                Padding(padding: const EdgeInsets.only(bottom: AppSizes.spaceMedium), child: _GuideSteps(guide: other)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideSteps extends StatelessWidget {
  const _GuideSteps({required this.guide});

  final InstallGuide guide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(guide.titleKey.tr, style: textTheme.titleSmall),
        const SizedBox(height: AppSizes.spaceXSmall),
        Text(guide.stepsKey.tr, style: textTheme.bodyMedium),
      ],
    );
  }
}
