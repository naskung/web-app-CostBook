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

  // จำนวนคอลัมน์ของการ์ด: ใส่ได้กี่ใบตามความกว้าง แล้วเกลี่ยให้แต่ละแถวเท่า ๆ กัน
  // เช่น 4 ใบ จอพอ 3 คอลัมน์ → 2 × 2 (ไม่ใช่ 3 + 1)
  static int gridColumns({
    required double width,
    required double minItemWidth,
    required int maxColumns,
    required int count,
  }) {
    if (count <= 0) return 1;
    final fit = (width / minItemWidth).floor().clamp(1, maxColumns);
    final rows = (count / fit).ceil();
    return (count / rows).ceil();
  }

  static double scaleOf(double width) {
    if (width <= designWidth) return 1;
    final scale = width / designWidth;
    if (scale > maxScale) return maxScale;
    return scale;
  }
}
