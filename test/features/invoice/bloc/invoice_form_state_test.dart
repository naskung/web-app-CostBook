import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/invoice/bloc/invoice_form_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/product/models/product_model.dart';

void main() {
  const keychain = ProductModel(id: 'p1', name: 'พวงกุญแจ', category: 'งานพิมพ์ 3D');
  const vase = ProductModel(id: 'p2', name: 'แจกัน', category: 'ของแต่งบ้าน');
  const case3d = ProductModel(id: 'p3', name: 'เคส', category: 'งานพิมพ์ 3D');
  const service = ProductModel(id: 'p4', name: 'ค่าออกแบบ');
  const state = InvoiceFormState(
    products: [keychain, vase, case3d, service],
    items: [InvoiceDraftItemModel(productId: 'p1', name: 'พวงกุญแจ', quantity: 3, unitPrice: 59)],
  );

  test('หมวดของสินค้า ไม่ซ้ำ เรียงตามชื่อ ไม่เอาหมวดว่าง', () {
    expect(state.productCategories, ['ของแต่งบ้าน', 'งานพิมพ์ 3D']);
  });

  test('กรองตามหมวด + คำค้น / หมวดว่าง = ทุกหมวด', () {
    expect(state.productsMatching('', category: 'งานพิมพ์ 3D'), [keychain, case3d]);
    expect(state.productsMatching('เคส', category: 'งานพิมพ์ 3D'), [case3d]);
    expect(state.productsMatching(''), hasLength(4));
  });

  test('จำนวนของสินค้าในบิล / ไม่อยู่ในบิล = 0', () {
    expect(state.quantityOf('p1'), 3);
    expect(state.quantityOf('p2'), 0);
  });
}
