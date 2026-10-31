import 'package:costbook/core/constants/screen_type.dart';

class ResponsiveUtil {
  static const double tabletMinWidth = 600;
  static const double desktopMinWidth = 1024;
  static const double designWidth = 1440;
  static const double maxScale = 2;

  static ScreenType typeOf(double width) {
    if (width < tabletMinWidth) return ScreenType.mobile;
    if (width < desktopMinWidth) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static double scaleOf(double width) {
    if (width <= designWidth) return 1;
    final scale = width / designWidth;
    if (scale > maxScale) return maxScale;
    return scale;
  }
}
