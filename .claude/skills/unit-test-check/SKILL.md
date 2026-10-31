---
name: unit-test-check
description: ตรวจสอบ unit test ของโปรเจกต์ CostBook — รัน flutter analyze และ flutter test, หาไฟล์ที่ยังไม่มี test, เขียน test แบบง่ายให้ utils / model / bloc / ไฟล์ภาษา แล้วรายงานผล ใช้ทุกครั้งหลังเขียนหรือแก้โค้ด Dart เสร็จ ก่อนบอกว่างานเสร็จ หรือเมื่อผู้ใช้ขอ "ตรวจ test", "รัน test", "เช็ค unit test". Use after any Dart code change and whenever asked to check or run tests.
---

# Unit Test Check

ถ้ายังไม่มี `pubspec.yaml` (ยังไม่ได้ `flutter create`) → แจ้งผู้ใช้ว่ายังไม่มีโปรเจกต์ Flutter แล้วหยุด

## ขั้นตอน (ทำตามลำดับ)

1. **ติดตั้ง package** (ครั้งแรก หรือเมื่อ `pubspec.yaml` เปลี่ยน)
   ```bash
   flutter pub get
   ```
2. **ตรวจโค้ด** — ต้องไม่มี error และ warning (info แจ้งผู้ใช้ได้ ไม่บังคับแก้)
   ```bash
   flutter analyze
   ```
3. **รัน test** — ต้องผ่านทั้งหมด
   ```bash
   flutter test
   ```
4. **หาไฟล์ที่ยังไม่มี test** — `lib/a/b.dart` ต้องมี `test/a/b_test.dart`
   ```bash
   for f in $(find lib \( -name '*_util.dart' -o -name '*_model.dart' -o -name '*_bloc.dart' \)); do
     t="test/${f#lib/}"
     t="${t%.dart}_test.dart"
     [ -f "$t" ] || echo "ยังไม่มี test: $f"
   done
   ```
5. **เขียน test ที่ขาด** ตามแม่แบบด้านล่าง แล้วกลับไปทำข้อ 3
6. **รายงานผล** ตามรูปแบบท้ายไฟล์

## อะไรต้องมี test

| ไฟล์ | บังคับ? | ทดสอบอะไร |
|---|---|---|
| `core/utils/*_util.dart` | บังคับ | ทุกฟังก์ชัน: ค่าปกติ + ค่าขอบ (0, ติดลบ, ค่าว่าง) |
| `features/*/models/*_model.dart` | บังคับ | `fromJson`, `toJson`, getter เช่น `isLowStock` |
| `features/*/bloc/*_bloc.dart` | บังคับ | ทุก event: กรณีสำเร็จ + กรณี error |
| `assets/lang/*.json` | บังคับ | `th.json` กับ `en.json` มี key ตรงกัน |
| `shared/widgets/atoms/` | ไม่บังคับ | widget test ง่าย ๆ ถ้ามีเวลา |
| pages, helpers, repository | ไม่ต้อง | — |

## กฎการเขียน test

- `test/` วางโครงเหมือน `lib/`
- 1 test เช็ค 1 เรื่อง
- ชื่อ test ภาษาไทย บอกผลที่คาดหวัง เช่น `'vat ของ 100 บาท ได้ 7 บาท'`
- ลำดับในแต่ละ test: เตรียมข้อมูล → เรียกใช้ → `expect`
- ไม่เรียก API จริง → mock repository ด้วย `mocktail`
- ยังไม่ใช้ golden test / integration test
- **ห้าม** ลบ test, ใส่ `skip`, หรือแก้ค่าใน `expect` เพื่อให้ผ่าน — ให้แก้โค้ดให้ถูก
  ถ้า test เขียนผิดจริง แก้ได้ แต่ต้องบอกผู้ใช้ว่าแก้เพราะอะไร
- `flutter test` รันบน Dart VM → โค้ดที่ใช้ `dart:html` / `package:web` รันไม่ได้ ให้เก็บโค้ดแบบนั้นไว้ใน `core/helpers` เท่านั้น

## แม่แบบ

### Util

```dart
// test/core/utils/tax_util_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/tax_util.dart';

void main() {
  group('TaxUtil', () {
    test('vat ของ 100 บาท ได้ 7 บาท', () {
      expect(TaxUtil.vat(100), 7);
    });

    test('ราคารวม vat ของ 100 บาท ได้ 107 บาท', () {
      expect(TaxUtil.totalWithVat(100), 107);
    });

    test('ถอด vat จาก 107 บาท ได้ 100 บาท', () {
      expect(TaxUtil.priceBeforeVat(107), 100);
    });
  });
}
```

```dart
// test/core/utils/cost_util_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/utils/cost_util.dart';

void main() {
  group('CostUtil', () {
    test('ต้นทุนรวม 1,000 บาท ผลิต 100 ชิ้น ได้ต้นทุนชิ้นละ 10 บาท', () {
      final result = CostUtil.costPerUnit(material: 500, labor: 300, overhead: 200, quantity: 100);
      expect(result, 10);
    });

    test('จำนวนผลิตเป็น 0 ได้ต้นทุน 0 (ไม่ error)', () {
      final result = CostUtil.costPerUnit(material: 500, labor: 0, overhead: 0, quantity: 0);
      expect(result, 0);
    });

    test('ต้นทุน 10 บาท markup 50% ได้ราคาขาย 15 บาท', () {
      expect(CostUtil.sellPrice(cost: 10, markupPercent: 50), 15);
    });
  });
}
```

### Model

```dart
// test/features/product/models/product_model_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/product/models/product_model.dart';

void main() {
  const product = ProductModel(
    id: '1',
    name: 'กาแฟ',
    unit: 'แก้ว',
    costPrice: 20,
    sellPrice: 45.5,
    stock: 10,
    minStock: 5,
  );

  group('ProductModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final json = {
        'id': '1',
        'name': 'กาแฟ',
        'unit': 'แก้ว',
        'cost_price': 20,
        'sell_price': 45.5,
        'stock': 10,
        'min_stock': 5,
      };
      expect(ProductModel.fromJson(json), product);
    });

    test('toJson แล้ว fromJson กลับมา ได้ค่าเดิม', () {
      expect(ProductModel.fromJson(product.toJson()), product);
    });

    test('isLowStock เป็น true เมื่อ stock เท่ากับ minStock', () {
      const lowProduct = ProductModel(
        id: '2', name: 'ชา', unit: 'แก้ว', costPrice: 15, sellPrice: 35, stock: 5, minStock: 5,
      );
      expect(lowProduct.isLowStock, true);
    });
  });
}
```

### Bloc

```dart
// test/features/product/bloc/product_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;

  const product = ProductModel(
    id: '1', name: 'กาแฟ', unit: 'แก้ว', costPrice: 20, sellPrice: 45, stock: 10, minStock: 5,
  );

  setUp(() {
    repository = MockProductRepository();
  });

  blocTest<ProductBloc, ProductState>(
    'LoadProducts สำเร็จ ได้ loading แล้ว success พร้อมรายการสินค้า',
    build: () {
      when(() => repository.getProducts()).thenAnswer((_) async => [product]);
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(LoadProducts()),
    expect: () => [
      const ProductState(status: AppStatus.loading),
      const ProductState(status: AppStatus.success, products: [product]),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'LoadProducts ล้มเหลว ได้ loading แล้ว failure',
    build: () {
      when(() => repository.getProducts()).thenThrow(Exception('error'));
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(LoadProducts()),
    expect: () => [
      const ProductState(status: AppStatus.loading),
      const ProductState(status: AppStatus.failure, errorMessage: 'Exception: error'),
    ],
  );
}
```

### ไฟล์ภาษา

```dart
// test/core/lang/lang_keys_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('th.json กับ en.json มี key ตรงกัน', () {
    final th = jsonDecode(File('assets/lang/th.json').readAsStringSync()) as Map<String, dynamic>;
    final en = jsonDecode(File('assets/lang/en.json').readAsStringSync()) as Map<String, dynamic>;
    expect(en.keys.toSet(), th.keys.toSet());
  });
}
```

## เมื่อ test ไม่ผ่าน

1. อ่าน `Expected:` กับ `Actual:` ใน error
2. ดูว่าโค้ดผิด หรือ test ผิด
3. แก้ทีละจุด แล้วรันเฉพาะไฟล์นั้น เช่น `flutter test test/core/utils/tax_util_test.dart`
4. ผ่านแล้ว รัน `flutter test` ทั้งหมดอีกรอบ

## รูปแบบรายงานผล

```
## ผลตรวจ Unit Test

| ขั้นตอน | ผล |
|---|---|
| flutter analyze | ผ่าน (0 issues) |
| flutter test | ผ่าน 24 / ไม่ผ่าน 0 |
| ไฟล์ที่ยังไม่มี test | ไม่มี |

test ที่เพิ่มใหม่: test/core/utils/tax_util_test.dart (3 tests)
```

ถ้ามี test ไม่ผ่าน ให้ระบุชื่อ test, ไฟล์ และสาเหตุทีละข้อ
ตรวจเสร็จแล้วอัปเดต `PROGRESS.md`
