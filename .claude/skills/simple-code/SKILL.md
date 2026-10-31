---
name: simple-code
description: กฎเขียนโค้ด Flutter/Dart แบบเรียบง่าย ไม่ซับซ้อน ของโปรเจกต์ CostBook ใช้ทุกครั้งก่อนเขียน แก้ หรือรีวิวโค้ด Dart ในโปรเจกต์นี้ ไม่ว่าจะเป็น bloc, model, repository, page, widget, route, utils หรือ helper. Use whenever writing, editing, or reviewing any Dart/Flutter code in this repo.
---

# Simple Code — เขียนโค้ดให้ง่ายที่สุด

เป้าหมาย: คนที่เพิ่งหัด Flutter อ่านแล้วเข้าใจได้ทันที

## หลักคิด

1. อ่านง่าย สำคัญกว่าสั้นหรือฉลาด
2. ทำเท่าที่ต้องใช้ตอนนี้ ไม่เขียนเผื่ออนาคต
3. ถ้ามีหลายวิธี เลือกวิธีที่ตรงไปตรงมาที่สุด
4. ทำตามโครงสร้างใน `docs/ARCHITECTURE.md` เสมอ ถ้าไม่แน่ใจว่าไฟล์ควรอยู่ไหน ให้เปิดดูหัวข้อ 3

## ทำ

- ฟังก์ชันละ 1 หน้าที่ ยาวไม่เกินประมาณ 30 บรรทัด
- หน้า (page) โค้ดเยอะ: `build()` ยาวเกินประมาณ 60 บรรทัด หรือไฟล์ยาวเกินประมาณ 150 บรรทัด → แยกส่วนย่อยเป็น extension ในไฟล์ `<ชื่อหน้า>_ext.dart` แล้วเรียกใช้ใน `build()` (ดูหัวข้อ "แยกโค้ดหน้าเป็น extension")
- widget (ไม่ใช่ page) `build()` ยาวเกินประมาณ 60 บรรทัด → แยกเป็น widget class ย่อย
- ใช้ `if` ธรรมดา + `return` เร็ว แทน `if` ซ้อนกันหลายชั้น
- ซ้อนกัน (nesting) ไม่เกิน 3 ชั้น
- ตั้งชื่อภาษาอังกฤษที่บอกความหมาย: `totalPrice` ไม่ใช่ `tp`, `products` ไม่ใช่ `list`
- เขียน `fromJson` / `toJson` เอง
- ข้อความบนจอใช้ `'key'.tr` และเพิ่ม key ทั้งใน `th.json` และ `en.json`
- ใช้ widget กลางใน `shared/widgets` ก่อนเสมอ
- โค้ดที่ใช้ตั้งแต่ 2 จุดขึ้นไป → แยกเป็นฟังก์ชันกลาง ห้าม copy-paste
  - ก่อนเขียนใหม่ ค้นใน `core/utils`, `core/helpers`, `shared/widgets` ก่อนว่ามีอยู่แล้วไหม
  - ใช้ซ้ำแค่ในไฟล์เดียว → private function (`_ชื่อ`) ในไฟล์นั้น
  - ใช้ซ้ำหลายไฟล์ ไม่ใช้ UI → `core/utils` (static function + เขียน test)
  - ใช้ซ้ำหลายไฟล์ ใช้ `BuildContext` / plugin → `core/helpers`
  - เป็น widget → `features/<ชื่อ>/widgets` ถ้าใช้ใน feature เดียว, `shared/widgets` ถ้าใช้หลาย feature
- คอมเมนต์ภาษาไทยสั้น ๆ เฉพาะจุดที่ไม่ชัด เช่น สูตรคำนวณ

## ห้าม

- ห้ามใช้ code generation: freezed, json_serializable, build_runner, injectable
- ห้ามเพิ่มชั้นแบบ Clean Architecture (usecase, entity, datasource, abstract repository + impl) — ใช้แค่ `model → repository → bloc → page`
- ห้ามใช้ get_it / service locator / GetX — สร้าง object ตรง ๆ ใน router
- ห้ามสร้าง base class / generic / mixin เพื่อใช้ซ้ำ ถ้ายังใช้ไม่ถึง 3 ที่ (ฟังก์ชันธรรมดาแยกได้ตั้งแต่ 2 ที่ — ดูหัวข้อ "ทำ")
- ห้ามเขียน extension เพิ่ม ยกเว้น `TrExtension` ของภาษา และ extension แยกโค้ดของหน้า (ดูหัวข้อ "แยกโค้ดหน้าเป็น extension")
- ห้ามใช้ Stream / RxDart เอง ถ้า Bloc ทำได้อยู่แล้ว
- ห้ามใช้ ternary ซ้อน (`a ? b : c ? d : e`)
- ห้ามใส่สูตรคำนวณใน widget หรือ bloc → ย้ายไป `core/utils`
- ห้ามใช้ `!` ถ้าไม่แน่ใจว่าไม่ null → ใช้ `?? ค่าเริ่มต้น`
- ห้ามเพิ่ม package ใหม่โดยไม่ถามผู้ใช้ก่อน

## แยกโค้ดหน้าเป็น extension

ใช้เมื่อหน้า (page) โค้ดเยอะจนอ่านยาก: `build()` ยาวเกินประมาณ 60 บรรทัด หรือไฟล์ยาวเกินประมาณ 150 บรรทัด

1. สร้างไฟล์ `<ชื่อหน้า>_ext.dart` ไว้ข้างไฟล์หน้า เช่น `product_list_page.dart` → `product_list_page_ext.dart`
2. ไฟล์หน้าเขียน `part '<ชื่อหน้า>_ext.dart';` ส่วนไฟล์ ext เขียน `part of '<ชื่อหน้า>.dart';` (แบบเดียวกับ event / state ของ bloc)
3. import ทั้งหมดอยู่ในไฟล์หน้า (ไฟล์ `part of` import เองไม่ได้)
4. 1 หน้า = 1 extension ชื่อ `_<ชื่อหน้า>Ext` — ชื่อ extension และชื่อ method ขึ้นต้นด้วย `_` (ใช้ได้แค่ในหน้านี้)
5. 1 method = 1 ส่วนของหน้า เช่น `_header`, `_filterBar`, `_content` — `build()` เหลือแค่เอาส่วนต่าง ๆ มาเรียงกัน
6. ต้องใช้ `context` → รับเป็น parameter เช่น `_header(BuildContext context)`
7. ห้ามเรียก `setState` ใน extension (analyzer เตือน `invalid_use_of_protected_member`) → เปลี่ยน state ผ่าน bloc
   หรือเขียน method ที่เรียก `setState` ไว้ในคลาส State แล้วให้ extension เรียก method นั้น
8. ห้ามใส่สูตรคำนวณ หรือเรียก repository ใน extension (กฎเดียวกับ page)
9. ส่วนที่ใช้ซ้ำตั้งแต่ 2 จุด → ไม่ใช้ extension ให้ทำเป็น widget class แทน (ตามกฎฟังก์ชันกลาง)

```dart
// lib/features/product/pages/product_list_page.dart
import 'package:flutter/material.dart';
// ... import ทุกอย่างที่ไฟล์ ext ใช้ ต้องอยู่ที่นี่

part 'product_list_page_ext.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(context),
        Expanded(child: _content()),
      ],
    );
  }
}
```

```dart
// lib/features/product/pages/product_list_page_ext.dart
part of 'product_list_page.dart';

extension _ProductListPageExt on ProductListPage {
  Widget _header(BuildContext context) {
    return Row(
      children: [
        Text('product.title'.tr),
        const Spacer(),
        AppButton(
          text: 'product.add'.tr,
          onPressed: () => context.push(AppRoutes.productAdd),
        ),
      ],
    );
  }

  Widget _content() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.status == AppStatus.loading) return const AppLoading();
        if (state.status == AppStatus.failure) return ErrorView(message: state.errorMessage);
        if (state.products.isEmpty) return EmptyView(message: 'product.empty'.tr);
        return ProductTable(products: state.products);
      },
    );
  }
}
```

## ตัวอย่าง

```dart
// ❌ ternary ซ้อน อ่านยาก
final label = stock <= 0 ? 'stock.out'.tr : stock <= minStock ? 'stock.low'.tr : 'stock.ok'.tr;

// ✅ if ธรรมดา
String stockLabel(int stock, int minStock) {
  if (stock <= 0) return 'stock.out'.tr;
  if (stock <= minStock) return 'stock.low'.tr;
  return 'stock.ok'.tr;
}
```

```dart
// ❌ คำนวณใน widget
Text('${(price * 7 / 100 + price).toStringAsFixed(2)}')

// ✅ เรียกใช้ util
MoneyText(value: TaxUtil.totalWithVat(price))
```

```dart
// ❌ copy สูตรเดียวกันไว้ 2 ที่
// invoice_bloc.dart
final vat = (price * 7 / 100 * 100).roundToDouble() / 100;
// cost_bloc.dart
final vat = (price * 7 / 100 * 100).roundToDouble() / 100;

// ✅ สูตรอยู่ที่เดียวใน lib/core/utils/tax_util.dart ทั้ง 2 bloc เรียกใช้
final vat = TaxUtil.vat(price);
```

```
❌ ชั้นเยอะเกิน
ProductBloc → GetProductsUseCase → ProductRepositoryImpl → ProductRemoteDataSource → ApiClient

✅ พอแล้ว
ProductBloc → ProductRepository → ApiClient
```

## Checklist ก่อนส่งงาน

- [ ] คนเพิ่งหัด Flutter อ่านแล้วเข้าใจไหม
- [ ] มีโค้ดที่ "เผื่อไว้" แต่ยังไม่ได้ใช้ไหม → ลบออก
- [ ] มีโค้ดซ้ำตั้งแต่ 2 จุดไหม → แยกเป็นฟังก์ชันกลาง
- [ ] หน้าไหนโค้ดเยอะ (`build()` > ~60 บรรทัด หรือไฟล์ > ~150 บรรทัด) → แยกเป็น extension ในไฟล์ `_ext.dart`
- [ ] ไฟล์อยู่ถูกโฟลเดอร์ตาม `docs/ARCHITECTURE.md`
- [ ] ไม่มีข้อความ hardcode (ใช้ `.tr`), ไม่มีสี / ขนาด hardcode (ใช้ `AppColors` / `AppSizes`)
- [ ] รัน skill `unit-test-check` แล้วผ่าน
- [ ] อัปเดต `PROGRESS.md` แล้ว
