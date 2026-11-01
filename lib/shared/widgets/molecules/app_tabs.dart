import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/app_badge.dart';

class AppTab {
  const AppTab({required this.value, required this.label, required this.icon, this.count});

  final String value;
  final String label;
  final IconData icon;
  final int? count;
}

// แท็บแบบแฟ้ม ใส่ไว้บนสุดของการ์ด (AppDataTable(header:)) หรือใต้หัว dialog (AppDialog(tabs:))
// แท็บที่เลือกสีเดียวกับพื้นที่อยู่ข้างใต้ (selectedColor: หัวตาราง = inputFill / dialog = surface) ต่อกันเป็นแผ่นเดียว
class AppTabs extends StatelessWidget {
  const AppTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.selectedColor = AppColors.inputFill,
  });

  final List<AppTab> tabs;
  final String selected;
  final ValueChanged<String> onChanged;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    // มือถือจอแคบ: ไม่แสดงไอคอน แท็บจะได้พอดีจอ
    final showIcon = ResponsiveHelper.screenType(context) != ScreenType.mobile;
    return Container(
      color: AppColors.tabStrip,
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceSmall, AppSizes.spaceSmall, AppSizes.spaceSmall, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tab in tabs)
              _TabButton(
                tab: tab,
                isSelected: tab.value == selected,
                selectedColor: selectedColor,
                showIcon: showIcon,
                onTap: () => onChanged(tab.value),
              ),
          ],
        ),
      ),
    );
  }
}

// แท็บที่เลือก: พื้นเดียวกับหัวตาราง + เส้นส้มด้านบน + ตัวหนังสือส้มเข้ม / ไม่ได้เลือก: ตัวหนังสือเทา ชี้เมาส์มีพื้นเทา
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.isSelected,
    required this.selectedColor,
    required this.showIcon,
    required this.onTap,
  });

  final AppTab tab;
  final bool isSelected;
  final Color selectedColor;
  final bool showIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryDark : AppColors.textSecondary;
    final count = tab.count;
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? selectedColor : AppColors.transparent,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radius)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.neutralSoft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMedium, vertical: AppSizes.tabPaddingY),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.transparent,
                  width: AppSizes.tabAccentHeight,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon) ...[
                  Icon(tab.icon, size: AppSizes.iconSmall, color: color),
                  const SizedBox(width: AppSizes.spaceSmall),
                ],
                Text(tab.label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
                if (count != null) ...[
                  const SizedBox(width: AppSizes.spaceSmall),
                  AppBadge(
                    text: '$count',
                    color: color,
                    backgroundColor: isSelected ? AppColors.primarySoft : AppColors.neutralSoft,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
