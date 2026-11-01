import 'package:flutter/material.dart';

import 'package:costbook/core/routes/app_menu.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/atoms/shop_logo.dart';

// ผู้ใช้ที่ login อยู่ แสดงเหนือปุ่มออกจากระบบ กดแล้วไปหน้า route (หน้าโปรไฟล์)
class SideMenuProfile {
  const SideMenuProfile({required this.name, required this.subtitle, required this.avatar, required this.route});

  final String name;
  final String subtitle;
  final Widget avatar;
  final String route;

  bool isSelected(String path) => path == route || path.startsWith('$route/');
}

// เมนูด้านข้าง: เมนูกลุ่ม (มี children) กดแล้วกาง / หุบ เมนูย่อยเยื้องเข้าไป
// กลุ่มที่มีหน้าปัจจุบันอยู่ข้างในกางให้เอง / แบบแคบ (ไอคอนอย่างเดียว) แสดงเมนูย่อยเป็นไอคอนเรียงกันไปเลย
class AppSideMenu extends StatefulWidget {
  const AppSideMenu({
    super.key,
    required this.title,
    required this.items,
    required this.currentPath,
    required this.logoutLabel,
    required this.onItemTap,
    required this.onLogout,
    this.profile,
  });

  final String title;
  final List<AppMenuItem> items;
  final String currentPath;
  final String logoutLabel;
  final ValueChanged<String> onItemTap;
  final VoidCallback onLogout;
  final SideMenuProfile? profile;

  @override
  State<AppSideMenu> createState() => _AppSideMenuState();
}

class _AppSideMenuState extends State<AppSideMenu> {
  // กลุ่มที่ผู้ใช้กดกาง / หุบเอง (key = labelKey) — ยังไม่เคยกด = กางเมื่อมีหน้าปัจจุบันอยู่ข้างใน
  final Map<String, bool> _expanded = {};

  bool _isExpanded(AppMenuItem group) => _expanded[group.labelKey] ?? group.isSelected(widget.currentPath);

  void _toggle(AppMenuItem group) {
    setState(() => _expanded[group.labelKey] = !_isExpanded(group));
  }

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
                  ..._profile(widget.profile, isCompact),
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    label: widget.logoutLabel,
                    isSelected: false,
                    isCompact: isCompact,
                    onTap: widget.onLogout,
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
              widget.title,
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

  List<Widget> _profile(SideMenuProfile? profile, bool isCompact) {
    if (profile == null) return const [];
    return [
      const Divider(color: AppColors.trackOnDark, height: AppSizes.spaceMedium),
      _ProfileTile(
        profile: profile,
        isSelected: profile.isSelected(widget.currentPath),
        isCompact: isCompact,
        onTap: () => widget.onItemTap(profile.route),
      ),
    ];
  }

  Widget _menuList(bool isCompact) {
    return ListView(
      children: [
        for (final item in widget.items)
          if (!item.hasChildren)
            _itemTile(item, isCompact)
          else if (isCompact)
            for (final child in item.children) _childTile(item, child, isCompact: true)
          else
            ..._group(item),
      ],
    );
  }

  Widget _itemTile(AppMenuItem item, bool isCompact) {
    return _MenuTile(
      icon: item.icon,
      label: item.label,
      isSelected: item.isSelected(widget.currentPath),
      isCompact: isCompact,
      onTap: () => widget.onItemTap(item.route),
    );
  }

  List<Widget> _group(AppMenuItem group) {
    final isExpanded = _isExpanded(group);
    return [
      _MenuTile(
        icon: group.icon,
        label: group.label,
        isSelected: false,
        isCompact: false,
        isHighlighted: group.isSelected(widget.currentPath),
        trailing: isExpanded ? Icons.expand_less : Icons.expand_more,
        onTap: () => _toggle(group),
      ),
      if (isExpanded)
        for (final child in group.children) _childTile(group, child, isCompact: false),
    ];
  }

  Widget _childTile(AppMenuItem group, AppMenuItem child, {required bool isCompact}) {
    return _MenuTile(
      icon: child.icon,
      label: child.label,
      isSelected: group.selectedChild(widget.currentPath) == child,
      isCompact: isCompact,
      isChild: !isCompact,
      onTap: () => widget.onItemTap(child.route),
    );
  }
}

// isHighlighted = หัวกลุ่มที่มีหน้าปัจจุบันอยู่ข้างใน (ตัวหนังสือสว่าง ไม่ทาสี) / isChild = เมนูย่อย (เยื้องเข้า)
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
    this.isHighlighted = false,
    this.isChild = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;
  final bool isHighlighted;
  final bool isChild;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.onPrimary : (isHighlighted ? AppColors.onDark : AppColors.onDarkSecondary);
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
              padding: EdgeInsets.fromLTRB(
                isCompact ? 0 : (isChild ? AppSizes.menuChildIndent : AppSizes.spaceMedium),
                isChild ? AppSizes.menuChildPaddingY : AppSizes.menuItemPaddingY,
                isCompact ? 0 : AppSizes.spaceMedium,
                isChild ? AppSizes.menuChildPaddingY : AppSizes.menuItemPaddingY,
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
        Icon(icon, color: color, size: isChild ? AppSizes.iconSmall : null),
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
        if (trailing != null) Icon(trailing, color: color, size: AppSizes.iconSmall),
      ],
    );
  }
}

// แถวผู้ใช้: รูป + ชื่อ + role / แบบแคบเหลือแต่รูป (ชี้แล้วเห็นชื่อ)
class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.profile, required this.isSelected, required this.isCompact, required this.onTap});

  final SideMenuProfile profile;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXSmall),
      child: Semantics(
        selected: isSelected,
        button: true,
        child: Material(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: InkWell(
            onTap: onTap,
            hoverColor: AppColors.menuHover,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? AppSizes.spaceXSmall : AppSizes.spaceSmall),
              child: isCompact ? Center(child: _ringedAvatar()) : _avatarAndName(context),
            ),
          ),
        ),
      ),
    );
    if (!isCompact) return tile;
    return Tooltip(message: profile.name, child: tile);
  }

  // ขอบขาวรอบรูป — รูปตัวอักษรย่อสีส้มไม่กลืนไปกับพื้นส้มตอนแถวนี้ถูกเลือก
  Widget _ringedAvatar() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.avatarRingWidth),
      decoration: const BoxDecoration(color: AppColors.onDark, shape: BoxShape.circle),
      child: profile.avatar,
    );
  }

  Widget _avatarAndName(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameColor = isSelected ? AppColors.onPrimary : AppColors.onDark;
    final subtitleColor = isSelected ? AppColors.onPrimary : AppColors.onDarkSecondary;
    return Row(
      children: [
        _ringedAvatar(),
        const SizedBox(width: AppSizes.spaceMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(color: nameColor),
              ),
              Text(
                profile.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
