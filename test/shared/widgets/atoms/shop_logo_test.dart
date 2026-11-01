import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/shared/widgets/atoms/shop_logo.dart';

void main() {
  String logoUrl(WidgetTester tester) {
    final image = tester.widget<Image>(find.byType(Image));
    return (image.image as NetworkImage).url;
  }

  testWidgets('ShopLogo.refresh() → URL โลโก้เปลี่ยน ทุกที่โหลดรูปใหม่ ไม่ใช้รูปเก่าที่จำไว้', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShopLogo(size: 48, radius: 8)));
    final before = logoUrl(tester);
    expect(before, startsWith(ApiConstants.companyLogoUrl));

    ShopLogo.refresh();
    await tester.pump();

    expect(logoUrl(tester), startsWith(ApiConstants.companyLogoUrl));
    expect(logoUrl(tester), isNot(before));
  });
}
