import 'package:flutter/widgets.dart';

import 'package:costbook/core/constants/screen_type.dart';
import 'package:costbook/core/utils/responsive_util.dart';

class ResponsiveHelper {
  static ScreenType screenType(BuildContext context) {
    return ResponsiveUtil.typeOf(MediaQuery.sizeOf(context).width);
  }
}
