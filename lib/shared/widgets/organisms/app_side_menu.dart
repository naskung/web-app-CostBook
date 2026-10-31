import 'package:flutter/material.dart';

import 'package:costbook/core/routes/app_menu.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/shop_logo.dart';

class AppSideMenu extends StatelessWidget {
  const AppSideMenu({
    super.key,
    required this.title,
    required this.items,
    required this.currentPath,
    required this.logoutLabel,
    required this.onItemTap,
    required this.onLogout,
  });

  final String title;
  final List<AppMenuItem> items;
  final String currentPath;
  final String logoutLabel;
  final ValueChanged<String> onItemTap;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.dark,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < AppSizes.sideMenuCompactBreak;
            return Padding(
              padding: const EdgeInsets.all(AppSizes.spaceMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context, isCompact),
                  const SizedBox(height: AppSizes.spaceLarge),
                  Expanded(child: _menuList(isCompact)),
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    label: logoutLabel,
                    isSelected: false,
                    isCompact: isCompact,
                    onTap: onLogout,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool isCompact) {
    const logo = ShopLogo(size: AppSizes.menuLogoSize, radius: AppSizes.radius);
    if (isCompact) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: AppSizes.spaceSmall), child: Center(child: logo));
    }
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceSmall),
      child: Row(
        children: [
          logo,
          const SizedBox(width: AppSizes.spaceMedium),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuList(bool isCompact) {
    return ListView(
      children: [
        for (final item in items)
          _MenuTile(
            icon: item.icon,
            label: item.label,
            isSelected: item.isSelected(currentPath),
            isCompact: isCompact,
            onTap: () => onItemTap(item.route),
          ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.onPrimary : AppColors.onDarkSecondary;
    final tile = Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceXSmall),
      child: Semantics(
        selected: isSelected,
        child: Material(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: InkWell(
            onTap: onTap,
            hoverColor: AppColors.menuHover,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 0 : AppSizes.spaceMedium,
                vertical: AppSizes.menuItemPaddingY,
              ),
              child: isCompact ? Center(child: Icon(icon, color: color)) : _iconAndLabel(context, color),
            ),
          ),
        ),
      ),
    );
    if (!isCompact) return tile;
    return Tooltip(message: label, child: tile);
  }

  Widget _iconAndLabel(BuildContext context, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: AppSizes.spaceMedium),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
