import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

// โครง dialog กลางของทั้งแอป:
// หัว (ไอคอน + ชื่อ + คำอธิบาย + ปุ่มปิด) → แท็บ (ถ้ามี) → เนื้อหาเลื่อนได้ (มีแถบเลื่อนเมื่อยาวเกิน) → notice → แถบปุ่มด้านล่าง
// มือถือ: ขอบจอแคบลง + ปุ่มด้านล่างกว้างเท่ากัน
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    this.subtitle = '',
    this.icon,
    this.closeLabel = '',
    this.canClose = true,
    this.notice,
    this.actions = const [],
    this.maxWidth = AppSizes.dialogMaxWidth,
    this.tabs,
  });

  final String title;
  final Widget child;
  final String subtitle;
  final IconData? icon;
  final String closeLabel;
  final bool canClose;
  final Widget? notice;
  final List<Widget> actions;
  final double maxWidth;

  // แท็บใต้หัว dialog (เช่น AppTabs รับเข้า / เบิกออก) แทนเส้นคั่น
  final Widget? tabs;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.screenType(context) == ScreenType.mobile;
    return Dialog(
      insetPadding: EdgeInsets.all(isMobile ? AppSizes.dialogMobileInset : AppSizes.spaceLarge),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            tabs ??
                const Divider(height: AppSizes.borderWidth, thickness: AppSizes.borderWidth, color: AppColors.border),
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  primary: true,
                  padding: const EdgeInsets.all(AppSizes.spaceLarge),
                  child: child,
                ),
              ),
            ),
            if (notice != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.spaceLarge, 0, AppSizes.spaceLarge, AppSizes.spaceMedium),
                child: notice,
              ),
            if (actions.isNotEmpty) _footer(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceLarge,
        AppSizes.spaceMedium,
        AppSizes.spaceSmall,
        AppSizes.spaceMedium,
      ),
      child: Row(
        children: [
          if (icon != null) ...[_IconBadge(icon: icon!), const SizedBox(width: AppSizes.spaceMedium)],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleLarge),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spaceXSmall),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: closeLabel.isEmpty ? null : closeLabel,
            onPressed: canClose ? () => Navigator.pop(context) : null,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _footer(bool isMobile) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceLarge, vertical: AppSizes.spaceMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSizes.spaceSmall),
              if (isMobile)
                Expanded(child: actions[i])
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: AppSizes.dialogButtonMinWidth),
                  child: actions[i],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.dialogIconBox,
      height: AppSizes.dialogIconBox,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Icon(icon, color: AppColors.onPrimary, size: AppSizes.iconSmall),
    );
  }
}
