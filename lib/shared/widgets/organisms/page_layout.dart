import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/routes/app_menu.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/shared/widgets/organisms/app_side_menu.dart';

class PageLayout extends StatefulWidget {
  const PageLayout({
    super.key,
    required this.title,
    required this.appName,
    required this.logoutLabel,
    required this.menuButtonLabel,
    required this.currentPath,
    required this.onNavigate,
    required this.onLogout,
    required this.child,
  });

  static const Duration menuAnimationDuration = Duration(milliseconds: 250);

  final String title;
  final String appName;
  final String logoutLabel;
  final String menuButtonLabel;
  final String currentPath;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;
  final Widget child;

  @override
  State<PageLayout> createState() => _PageLayoutState();
}

class _PageLayoutState extends State<PageLayout> {
  bool _isMenuExpanded = true;

  void _toggleMenu() {
    setState(() => _isMenuExpanded = !_isMenuExpanded);
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.screenType(context) == ScreenType.desktop) {
      return _desktopLayout();
    }
    return _mobileLayout();
  }

  Widget _desktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: PageLayout.menuAnimationDuration,
          curve: Curves.easeInOutCubic,
          width: _isMenuExpanded ? AppSizes.sideMenuWidth : AppSizes.sideMenuCollapsedWidth,
          child: _sideMenu(widget.onNavigate),
        ),
        Expanded(
          child: Scaffold(
            appBar: AppBar(leading: _toggleButton(), title: Text(widget.title)),
            body: widget.child,
          ),
        ),
      ],
    );
  }

  Widget _toggleButton() {
    return IconButton(
      onPressed: _toggleMenu,
      tooltip: widget.menuButtonLabel,
      icon: AnimatedSwitcher(
        duration: PageLayout.menuAnimationDuration,
        child: Icon(
          _isMenuExpanded ? Icons.menu_open_rounded : Icons.menu,
          key: ValueKey(_isMenuExpanded),
        ),
      ),
    );
  }

  Widget _mobileLayout() {
    return Scaffold(
      appBar: AppBar(leading: _drawerButton(), title: Text(widget.title)),
      drawer: Drawer(
        backgroundColor: AppColors.dark,
        child: Builder(
          builder: (drawerContext) => _sideMenu((route) {
            Scaffold.of(drawerContext).closeDrawer();
            widget.onNavigate(route);
          }),
        ),
      ),
      body: widget.child,
    );
  }

  Widget _drawerButton() {
    return Builder(
      builder: (scaffoldContext) => IconButton(
        onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
        tooltip: widget.menuButtonLabel,
        icon: const Icon(Icons.menu),
      ),
    );
  }

  Widget _sideMenu(ValueChanged<String> onItemTap) {
    return AppSideMenu(
      title: widget.appName,
      items: AppMenu.items,
      currentPath: widget.currentPath,
      logoutLabel: widget.logoutLabel,
      onItemTap: onItemTap,
      onLogout: widget.onLogout,
    );
  }
}
