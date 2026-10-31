import 'package:costbook/core/utils/money_util.dart';

class DocumentAmounts {
  const DocumentAmounts({
    required this.itemsTotal,
    required this.discount,
    required this.subtotal,
    required this.vat,
    required this.total,
  });

  final double itemsTotal;
  final double discount;
  final double subtotal;
  final double vat;
  final double total;
}

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

  static DocumentAmounts documentAmounts({
    required double itemsTotal,
    required double discount,
    required bool vatRegistered,
    required bool pricesIncludeVat,
  }) {
    final afterDiscount = MoneyUtil.round2(itemsTotal - discount);
    if (!vatRegistered) {
      return DocumentAmounts(
        itemsTotal: itemsTotal,
        discount: discount,
        subtotal: afterDiscount,
        vat: 0,
        total: afterDiscount,
      );
    }
    if (pricesIncludeVat) {
      final subtotal = priceBeforeVat(afterDiscount);
      return DocumentAmounts(
        itemsTotal: itemsTotal,
        discount: discount,
        subtotal: subtotal,
        vat: MoneyUtil.round2(afterDiscount - subtotal),
        total: afterDiscount,
      );
    }
    return DocumentAmounts(
      itemsTotal: itemsTotal,
      discount: discount,
      subtotal: afterDiscount,
      vat: vat(afterDiscount),
      total: totalWithVat(afterDiscount),
    );
  }
}
