import 'package:flutter/widgets.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/responsive_util.dart';

class ResponsiveHelper {
  static ScreenType screenType(BuildContext context) {
    return ResponsiveUtil.typeOf(MediaQuery.sizeOf(context).width);
  }

  static double pagePadding(BuildContext context) {
    if (screenType(context) == ScreenType.mobile) return AppSizes.spaceMedium;
    return AppSizes.spaceLarge;
  }
}
