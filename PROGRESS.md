# CostBook Web — ความคืบหน้า

> ทุกครั้งที่ทำงานเสร็จ: ติ๊ก `[x]` ในรายการ และเพิ่ม 1 บรรทัดใน "บันทึกการทำงาน" (ล่าสุดอยู่บนสุด)

## สถานะตอนนี้

- **เสร็จแล้ว:** Phase 0 — เอกสารและกติกา
- **งานถัดไป:** Phase 1 — สร้างโปรเจกต์ Flutter

---

## Phase 0 — เอกสารและกติกา

- [x] โครงสร้างและกติกาโปรเจกต์ `docs/ARCHITECTURE.md`
- [x] `CLAUDE.md` (กฎที่ Claude อ่านทุกครั้ง)
- [x] skill `simple-code` — เขียนโค้ดแบบง่าย ไม่ซับซ้อน
- [x] skill `unit-test-check` — ตรวจ / รัน / เขียน unit test
- [x] `PROGRESS.md` (ไฟล์นี้)

## Phase 1 — ตั้งค่าโปรเจกต์

- [ ] `flutter create --platforms web --project-name costbook .`
- [ ] เพิ่ม package (flutter_bloc, equatable, go_router, http, intl, pdf, printing, bloc_test, mocktail)
- [ ] สร้างโฟลเดอร์ตาม `docs/ARCHITECTURE.md`

## Phase 2 — Core

- [ ] theme: `AppColors`, `AppSizes`, `AppTheme`
- [ ] `AppStatus`
- [ ] ภาษา: `AppLang` + `.tr` + `th.json` / `en.json` + `LanguageBloc`
- [ ] route: `AppRoutes` + `appRouter` (ShellRoute)
- [ ] `ApiClient`
- [ ] utils + test: `MoneyUtil`, `TaxUtil`, `CostUtil`, `DateUtil`, `ValidatorUtil`
- [ ] helpers: `DialogHelper`, `SnackbarHelper`
- [ ] test เช็ค key ภาษา th / en ตรงกัน

## Phase 3 — Widget กลาง

- [ ] atoms: `AppButton`, `AppTextField`, `AppDropdown`, `AppLoading`, `AppBadge`, `MoneyText`
- [ ] molecules: `SearchField`, `StatCard`, `AmountRow`, `EmptyView`, `ErrorView`
- [ ] organisms: `PageLayout`, `AppSideMenu`, `AppTopBar`, `AppDataTable`, `FormCard`

## Phase 4 — Features

แต่ละ feature: model + test → repository → bloc + test → pages → widgets

- [ ] product — จัดการสินค้า
- [ ] cost — คำนวณต้นทุน / ราคาขาย
- [ ] stock — รับเข้า / เบิกออก / ใกล้หมด
- [ ] transaction — รายรับ-รายจ่าย + สรุปรายเดือน
- [ ] invoice — ใบกำกับภาษี + VAT 7% + PDF (ฟอนต์ไทย)
- [ ] dashboard — สรุปภาพรวม
- [ ] settings — ข้อมูลบริษัท + เปลี่ยนภาษา

## Phase 5 — ส่งงาน

- [ ] ต่อ API จริง (`../api-Costbook`) แทนข้อมูลตัวอย่าง
- [ ] `flutter analyze` และ `flutter test` ผ่านทั้งหมด
- [ ] `flutter build web`
- [ ] deploy

---

## เรื่องที่ยังต้องตัดสินใจ

- [ ] deploy ที่ไหน (Firebase Hosting / Vercel / server เอง)
- [ ] ต้องมี login / ผู้ใช้หลายคนไหม
- [ ] ออกใบกำกับแล้วให้ตัด stock และบันทึกรายรับอัตโนมัติไหม (แนะนำให้ API ทำ)
- [ ] รูปแบบเลขที่ใบกำกับ (แนะนำให้ API รันเลข)

---

## บันทึกการทำงาน

| วันที่ | ทำอะไร | หมายเหตุ |
|---|---|---|
| 2026-10-31 | สร้าง `docs/ARCHITECTURE.md`, `CLAUDE.md`, `PROGRESS.md`, skill `simple-code` และ `unit-test-check` | ยังไม่มีโค้ด Flutter |
