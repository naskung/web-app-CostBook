import 'package:costbook/core/utils/money_util.dart';
import 'package:costbook/core/utils/percent_util.dart';
import 'package:costbook/core/utils/tax_util.dart';

class MarketUtil {
  static const String below = 'below';
  static const String within = 'within';
  static const String above = 'above';
  static const String unknown = 'unknown';

  static double customerPrice({
    required double sellPrice,
    required bool vatRegistered,
    required bool pricesIncludeVat,
  }) {
    if (vatRegistered && !pricesIncludeVat) return TaxUtil.totalWithVat(sellPrice);
    return MoneyUtil.round2(sellPrice);
  }

  static String position({required double price, required double low, required double high}) {
    if (low <= 0 && high <= 0) return unknown;
    if (price < low) return below;
    if (high > 0 && price > high) return above;
    return within;
  }

  static double diffPercent({required double price, required double typical}) {
    if (typical <= 0) return 0;
    return PercentUtil.of(part: price - typical, total: typical);
  }

  static double placeInRange({required double value, required double low, required double high}) {
    if (high <= low) return 0.5;
    return ((value - low) / (high - low)).clamp(0.0, 1.0);
  }
}
