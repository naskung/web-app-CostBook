# CostBook Web App

Flutter Web สำหรับ: คำนวณต้นทุนสินค้า, ออกใบกำกับภาษี, บันทึกรายรับ-รายจ่าย, เช็ค stock
Backend อยู่ที่ repo `../api-Costbook`

## อ่านก่อนเริ่มงานทุกครั้ง

1. `docs/ARCHITECTURE.md` — โครงสร้างและกติกาทั้งหมด
2. `PROGRESS.md` — ทำอะไรไปแล้ว และงานถัดไปคืออะไร

## กฎหลัก

- เขียนโค้ดแบบ **simple** เสมอ → ใช้ skill `simple-code`
- เขียน / แก้โค้ดเสร็จ → ใช้ skill `unit-test-check` ก่อนบอกว่างานเสร็จ
- ทำงานเสร็จ → อัปเดต `PROGRESS.md` (ติ๊ก checklist + เพิ่มบรรทัดในบันทึกการทำงาน)
- โครงสร้าง: BLoC + Model + Repository, widget แบบ atoms / molecules / organisms, `core/utils` / `core/helpers`, route อยู่ใน `core/routes`
- ข้อความบนหน้าจอใช้ `'key'.tr` เท่านั้น (ไฟล์ `assets/lang/th.json`, `en.json`)
- import แบบ `package:costbook/...`
- จะเพิ่ม package ใหม่ → ถามผู้ใช้ก่อน
- ตอบผู้ใช้เป็นภาษาไทย

## คำสั่ง

```bash
flutter run -d chrome
flutter analyze
flutter test
flutter build web
```
