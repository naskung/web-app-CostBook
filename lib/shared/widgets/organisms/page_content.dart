import 'package:flutter/material.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/helpers/responsive_helper.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.children, this.centerChild, this.maxWidth = AppSizes.contentMaxWidth});

  final List<Widget> children;
  final Widget? centerChild;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final padding = _padding(context);
    final hasCenterChild = centerChild != null;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(padding, padding, padding, hasCenterChild ? 0 : padding),
          sliver: SliverToBoxAdapter(
            child: _limitWidth(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)),
          ),
        ),
        if (hasCenterChild)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: padding),
              child: _limitWidth(centerChild ?? const SizedBox()),
            ),
          ),
      ],
    );
  }

  Widget _limitWidth(Widget child) {
    return Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
  }

  double _padding(BuildContext context) {
    if (ResponsiveHelper.screenType(context) == ScreenType.mobile) return AppSizes.spaceMedium;
    return AppSizes.spaceLarge;
  }
}
