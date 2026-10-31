import 'package:costbook/core/utils/money_util.dart';

class TaxUtil {
  static const double vatPercent = 7;

  static double vat(double priceBeforeVat) {
    return MoneyUtil.round2(priceBeforeVat * vatPercent / 100);
  }

  static double totalWithVat(double priceBeforeVat) {
    return MoneyUtil.round2(priceBeforeVat + vat(priceBeforeVat));
  }

  static double priceBeforeVat(double totalWithVat) {
    return MoneyUtil.round2(totalWithVat * 100 / (100 + vatPercent));
  }
}
