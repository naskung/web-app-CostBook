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
- `build()` ยาวเกินประมาณ 60 บรรทัด → แยกเป็น widget class ใหม่
- ใช้ `if` ธรรมดา + `return` เร็ว แทน `if` ซ้อนกันหลายชั้น
- ซ้อนกัน (nesting) ไม่เกิน 3 ชั้น
- ตั้งชื่อภาษาอังกฤษที่บอกความหมาย: `totalPrice` ไม่ใช่ `tp`, `products` ไม่ใช่ `list`
- เขียน `fromJson` / `toJson` เอง
- ข้อความบนจอใช้ `'key'.tr` และเพิ่ม key ทั้งใน `th.json` และ `en.json`
- ใช้ widget กลางใน `shared/widgets` ก่อนเสมอ
- คอมเมนต์ภาษาไทยสั้น ๆ เฉพาะจุดที่ไม่ชัด เช่น สูตรคำนวณ

## ห้าม

- ห้ามใช้ code generation: freezed, json_serializable, build_runner, injectable
- ห้ามเพิ่มชั้นแบบ Clean Architecture (usecase, entity, datasource, abstract repository + impl) — ใช้แค่ `model → repository → bloc → page`
- ห้ามใช้ get_it / service locator / GetX — สร้าง object ตรง ๆ ใน router
- ห้ามสร้าง base class / generic / mixin เพื่อใช้ซ้ำ ถ้ายังใช้ไม่ถึง 3 ที่
- ห้ามเขียน extension เพิ่ม (มีได้แค่ `TrExtension` ของภาษา)
- ห้ามใช้ Stream / RxDart เอง ถ้า Bloc ทำได้อยู่แล้ว
- ห้ามใช้ ternary ซ้อน (`a ? b : c ? d : e`)
- ห้ามใส่สูตรคำนวณใน widget หรือ bloc → ย้ายไป `core/utils`
- ห้ามใช้ `!` ถ้าไม่แน่ใจว่าไม่ null → ใช้ `?? ค่าเริ่มต้น`
- ห้ามเพิ่ม package ใหม่โดยไม่ถามผู้ใช้ก่อน

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

```
❌ ชั้นเยอะเกิน
ProductBloc → GetProductsUseCase → ProductRepositoryImpl → ProductRemoteDataSource → ApiClient

✅ พอแล้ว
ProductBloc → ProductRepository → ApiClient
```

## Checklist ก่อนส่งงาน

- [ ] คนเพิ่งหัด Flutter อ่านแล้วเข้าใจไหม
- [ ] มีโค้ดที่ "เผื่อไว้" แต่ยังไม่ได้ใช้ไหม → ลบออก
- [ ] ไฟล์อยู่ถูกโฟลเดอร์ตาม `docs/ARCHITECTURE.md`
- [ ] ไม่มีข้อความ hardcode (ใช้ `.tr`), ไม่มีสี / ขนาด hardcode (ใช้ `AppColors` / `AppSizes`)
- [ ] รัน skill `unit-test-check` แล้วผ่าน
- [ ] อัปเดต `PROGRESS.md` แล้ว
