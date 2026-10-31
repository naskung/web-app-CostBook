import 'package:costbook/core/utils/money_util.dart';

class CostUtil {
  static double lineAmount({required double quantity, required double unitPrice}) {
    return MoneyUtil.round2(quantity * unitPrice);
  }

  static double percentOf({required double base, required double percent}) {
    return MoneyUtil.round2(base * percent / 100);
  }

  static double costPerUnit({
    required double material,
    required double labor,
    required double overhead,
    required int quantity,
  }) {
    if (quantity <= 0) return 0;
    return MoneyUtil.round2((material + labor + overhead) / quantity);
  }

  static double sellPrice({required double cost, required double markupPercent}) {
    return MoneyUtil.round2(cost * (1 + markupPercent / 100));
  }

  static double profitPerUnit({required double sellPrice, required double cost}) {
    return MoneyUtil.round2(sellPrice - cost);
  }

  static double markupPercent({required double sellPrice, required double cost}) {
    if (cost <= 0) return 0;
    return MoneyUtil.round2((sellPrice - cost) * 100 / cost);
  }
}
