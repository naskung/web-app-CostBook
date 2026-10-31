# CostBook Web — ความคืบหน้า

> ทุกครั้งที่ทำงานเสร็จ: ติ๊ก `[x]` ในรายการ และเพิ่ม 1 บรรทัดใน "บันทึกการทำงาน" (ล่าสุดอยู่บนสุด)

## สถานะตอนนี้

- **เสร็จแล้ว:** Phase 0, Phase 1 (เหลือ package intl / pdf / printing), theme + responsive + ภาษา ของ Phase 2, **login ต่อ API จริงแล้ว** (route `/login` ↔ `/`, จดจำการเข้าสู่ระบบ, ปุ่มออกจากระบบ)
- **งานถัดไป:** รอผู้ใช้สั่ง — เช่น หน้าแรก / `PageLayout` (เมนูข้าง + แถบบน ย้ายปุ่มออกจากระบบไปไว้ในนั้น), จัดการ 401 `unauthorized` (token หมดอายุ)

---

## Phase 0 — เอกสารและกติกา

- [x] โครงสร้างและกติกาโปรเจกต์ `docs/ARCHITECTURE.md`
- [x] `CLAUDE.md` (กฎที่ Claude อ่านทุกครั้ง)
- [x] skill `simple-code` — เขียนโค้ดแบบง่าย ไม่ซับซ้อน
- [x] skill `unit-test-check` — ตรวจ / รัน / เขียน unit test
- [x] `PROGRESS.md` (ไฟล์นี้)

## Phase 1 — ตั้งค่าโปรเจกต์

- [x] `flutter create --platforms web --project-name costbook .`
- [x] เพิ่ม package สำหรับ login: flutter_bloc, equatable, http, go_router, shared_preferences, bloc_test, mocktail
- [ ] เพิ่ม package ที่เหลือ: intl, pdf, printing (เพิ่มตอนทำ feature ที่ใช้)
- [x] สร้างโฟลเดอร์ตาม `docs/ARCHITECTURE.md` (โฟลเดอร์ว่างมี `.gitkeep` ลบได้เมื่อมีไฟล์จริง)

## Phase 2 — Core

- [x] theme: `AppColors`, `AppSizes`, `AppTheme` + ฟอนต์ LINESeedSansTH
- [x] รองรับทุกขนาดจอ: `ScreenType`, `ResponsiveUtil` + test, `ResponsiveHelper`, `ScreenScaler` (จอใหญ่ขยายทั้งแอป) + test
- [x] `AppStatus`
- [x] ภาษา: `AppLang` + `.tr` + `th.json` / `en.json`
- [ ] `LanguageBloc`
- [x] route: `AppRoutes` + `appRouter` (`/login`, `/` + redirect ตาม token)
- [ ] route: ShellRoute + `PageLayout`
- [x] `ApiClient` (`post` + แนบ token ให้เอง + `ApiException`) + test — `get` / `put` / `delete` เพิ่มตอนมี feature ที่ใช้
- [x] utils + test: `ValidatorUtil` (required, email)
- [ ] utils + test: `MoneyUtil`, `TaxUtil`, `CostUtil`, `DateUtil`
- [ ] helpers: `DialogHelper`, `SnackbarHelper`
- [x] test เช็ค key ภาษา th / en ตรงกัน

## Phase 3 — Widget กลาง

- [x] atoms: `AppButton` (มี `isLoading`), `AppTextField` (มีปุ่มแสดง / ซ่อนรหัสผ่าน)
- [ ] atoms: `AppDropdown`, `AppLoading`, `AppBadge`, `MoneyText`
- [ ] molecules: `SearchField`, `StatCard`, `AmountRow`, `EmptyView`, `ErrorView`
- [ ] organisms: `PageLayout`, `AppSideMenu`, `AppTopBar`, `AppDataTable`, `FormCard`

## Phase 4 — Features

แต่ละ feature: model + test → repository → bloc + test → pages → widgets

- [x] auth — login: UI + `AuthBloc` + `AuthRepository` + ต่อ API `POST /auth/login` + route `/login` + จดจำ token (`shared_preferences`) + logout + test
- [ ] auth — ได้ 401 `unauthorized` → ลบ token แล้วไปหน้า login (ทำตอนมี API ที่ต้อง login)
- [ ] product — จัดการสินค้า
- [ ] cost — คำนวณต้นทุน / ราคาขาย
- [ ] stock — รับเข้า / เบิกออก / ใกล้หมด
- [ ] transaction — รายรับ-รายจ่าย + สรุปรายเดือน
- [ ] invoice — ใบกำกับภาษี + VAT 7% + PDF (ฟอนต์ไทย)
- [ ] dashboard — สรุปภาพรวม (ตอนนี้มีแค่หน้าเปล่า + ปุ่มออกจากระบบ)
- [ ] settings — ข้อมูลบริษัท + โลโก้ร้าน (แต่ละร้านต่างกัน ไม่ฝังในแอป) + เปลี่ยนภาษา

## Phase 5 — ส่งงาน

- [ ] ต่อ API จริง (`../api-Costbook`) แทนข้อมูลตัวอย่าง
- [ ] `flutter analyze` และ `flutter test` ผ่านทั้งหมด
- [ ] `flutter build web`
- [ ] deploy

---

## เรื่องที่ยังต้องตัดสินใจ

- [ ] deploy ที่ไหน (Firebase Hosting / Vercel / server เอง)
- [x] ต้องมี login ไหม → มี (อีเมล + รหัสผ่าน ตาม API)
- [ ] มีผู้ใช้หลายคน / แบ่งสิทธิ์ไหม
- [ ] ออกใบกำกับแล้วให้ตัด stock และบันทึกรายรับอัตโนมัติไหม (แนะนำให้ API ทำ)
- [ ] รูปแบบเลขที่ใบกำกับ (แนะนำให้ API รันเลข)

---

## บันทึกการทำงาน

| วันที่ | ทำอะไร | หมายเหตุ |
|---|---|---|
| 2026-10-31 | **ต่อ API login**: เพิ่ม package flutter_bloc, equatable, http, go_router, shared_preferences, bloc_test, mocktail / `ApiConstants`, `AppStatus`, `ApiClient` + `ApiException`, `AuthRepository` (login / logout / loadSavedToken), `AuthBloc` (`LoginSubmitted`, `LogoutRequested`), `AppRoutes` + `appRouter` (redirect: ไม่มี token → `/login`), `DashboardPage` (หน้าแรกเปล่า + ปุ่มออกจากระบบ), `AppButton.isLoading`, หน้า login แสดง error `'error.<code>'.tr` + ปุ่มหมุนตอนรอ, key ภาษา `common.logout`, `dashboard.welcome`, `error.*` (invalid_credentials, email_required, password_required, server_error, network_error, unknown_error) | analyze ผ่าน, test 68 ผ่าน (เพิ่ม api_client 8, auth_repository 6, auth_bloc 4, login_page 6, dashboard_page 2), `flutter build web` ผ่าน, ลองเรียก API จริงด้วย `ApiClient`: รหัสถูกได้ token / รหัสผิด + ไม่มีอีเมลได้ `invalid_credentials`, CORS preflight 204 — **ยังไม่ได้ดูภาพจริงใน Chrome** / ยังไม่จัดการ token หมดอายุ (`error.unauthorized` ยังไม่เพิ่ม) |
| 2026-10-31 | **(จาก api-Costbook) API ข้อมูลร้าน + โลโก้ พร้อมใช้** (1 ระบบ = 1 ร้าน แก้ข้อมูลร้านผ่าน API หน้าเว็บไม่ต้องแก้): `GET /api/v1/company` → `{"name","address","tax_id","branch","phone","has_logo"}` (ไม่ต้อง login) / `PUT /api/v1/company` (ต้อง login) ส่งครบทุกช่อง → 400 `company_name_required`, `company_tax_id_invalid` / `GET /api/v1/company/logo` → รูปตรง ๆ ใช้ `Image.network` ได้ (ไม่ต้อง login) 404 `logo_not_found` = แสดงโลโก้ CostBook แทน / `PUT /api/v1/company/logo` multipart ช่อง `logo` PNG / JPG / WebP ≤ 1 MB → 400 `logo_required`, `logo_too_large`, `logo_type_invalid` / `DELETE /api/v1/company/logo` → 204 | ยังไม่ได้แก้โค้ด Flutter — ใช้ในหน้า settings + หน้า login + PDF ใบกำกับ, เพิ่ม key `error.<code>` ข้างบนใน `th.json` / `en.json`, หลังอัปโหลดโลโก้ใหม่ต้องล้าง cache รูป (`imageCache` / ใส่ key ใหม่) — รายละเอียด: `../api-Costbook/docs/ARCHITECTURE.md` หัวข้อ 7 หรือ `http://localhost:8080/docs` |
| 2026-10-31 | ปิดแถบ DEBUG มุมขวาบน (`debugShowCheckedModeBanner: false` ใน `app.dart`) | |
| 2026-10-31 | กลับไปใช้พื้นหลังแบบแบ่งบน-ล่าง แล้วตกแต่งครึ่งบน: ไล่สีเทาเข้ม, ขอบล่างโค้ง, แถบเฉียงสีส้มมุมขวาบน (ตำแหน่งตามสัดส่วนจอ ไม่ทับตัวหนังสือบนมือถือ), แสงส้มมุมขวาบน / ซ้ายล่าง, ลายจุดจาง ๆ | ผู้ใช้ชอบแบบแบ่ง แค่อยากให้ครึ่งบนสวยขึ้น, test 42 ผ่าน, ดูภาพจริงใน Chrome 375 / 768 / 1072x1782 / 1440 / 2560 แล้ว |
| 2026-10-31 | พื้นหลังหน้า login ใหม่: เทาเข้มเต็มจอ + แสงส้มมุมซ้ายบน / ขวาล่าง + ลายจุดจาง ๆ แยกเป็น `LoginBackground` (features/auth/widgets) แทนแบบแบ่งครึ่งบน-ล่าง | test 42 ผ่าน, ดูภาพจริงใน Chrome 375 / 768 / 1072x1782 / 1440 / 2560 แล้ว |
| 2026-10-31 | ออกแบบหน้า login ใหม่ทั้งหมด: เอาแถบรูปด้านข้าง + โลโก้ / รูป MakeHub ออก, ใช้หน้าเดียวทุกขนาดจอ (ครึ่งบนเทาเข้ม + แสงส้ม, ชื่อแอป CostBook, การ์ดฟอร์มกลางจอ), ชื่อช่องอยู่เหนือช่องกรอก + ตัวอย่างในช่อง, Enter ไปช่องถัดไป, autofill รหัสผ่าน, ปุ่มส้มตัวหนังสือเข้ม (อ่านชัด) | โลโก้ขึ้นกับแต่ละร้าน → ย้ายไปทำในหน้า settings, ลบ `assets/images/*` + `AppImages`, test 42 ผ่าน, ดูภาพจริงใน Chrome 320–2560 แล้ว |
| 2026-10-31 | **(จาก api-Costbook) API login พร้อมใช้:** `POST /api/v1/auth/login` ส่ง `{"email","password"}` → 200 `{"token","user":{"id","email","first_name","last_name"}}` / 400 `invalid_json`, `email_required`, `password_required` / 401 `invalid_credentials` — `GET /api/v1/auth/me` ส่ง header `Authorization: Bearer <token>` → 200 user / 401 `unauthorized` (ให้ลบ token แล้วไปหน้า login) — token อายุ 7 วัน, ผู้ใช้ทดสอบ `admin@costbook.com` / `1234` | ยังไม่ได้แก้โค้ด Flutter — ต้องเพิ่ม key `error.invalid_credentials`, `error.email_required`, `error.password_required`, `error.unauthorized` ใน `th.json` / `en.json` ตอนต่อ API — รายละเอียด: `../api-Costbook/docs/ARCHITECTURE.md` หัวข้อ 7 |
| 2026-10-31 | หน้า login จอคอม: เพิ่มโลโก้ด้านบนฟอร์ม (รวมเป็น `_logoAndForm` ใช้ร่วมกับการ์ดของแท็บเล็ต) + test โลโก้ทุกขนาดจอ | test 45 ผ่าน, ดูภาพจริงที่ 1100 และ 1440 แล้ว |
| 2026-10-31 | ออกแบบหน้า login ใหม่ด้วยโลโก้และสีของ MakeHub (ส้ม `#FD7402` + เทาเข้ม `#1B2228`) + checkbox จดจำการเข้าสู่ระบบ, เพิ่ม `assets/images/` (logo.png, logo_light.png, login_photo.jpg) + `AppImages` | โลโก้พื้นใส 2 แบบทำจากไฟล์ที่ผู้ใช้ส่งมา ตัดบรรทัดหมวดหมู่ออก (แสดงเป็นข้อความแทน), รูปพื้นหลังตัดจากแบนเนอร์ส่วนที่ไม่มีตัวหนังสือ, ดูภาพจริงใน Chrome ทุกขนาด, test 42 ผ่าน |
| 2026-10-31 | หน้า login (UI): `LoginPage` + `_ext.dart`, ระบบภาษา `AppLang` + `.tr` + `th.json` / `en.json`, `ValidatorUtil`, atoms `AppButton` / `AppTextField`, theme ปุ่ม / ช่องกรอก / การ์ด + test | มือถือ = ฟอร์มเต็มจอ, แท็บเล็ต = การ์ดกลางจอ, จอคอม = แถบแบรนด์ซ้าย + การ์ด, จอใหญ่ = ขยายตามสัดส่วน — ดูภาพจริงใน Chrome ที่ 320 / 375 / 768 / 1280 / 1440 / 2560 แล้ว, test 39 ผ่าน |
| 2026-10-31 | ลบคอมเมนต์ทั้งหมดในโค้ด (`lib/`, `test/`, `pubspec.yaml`) และเปลี่ยนกฎใน skill `simple-code` เป็น "ไม่เขียนคอมเมนต์ในโค้ด" | ยกเว้น `// TODO: ต่อ API` ใน repository |
| 2026-10-31 | รองรับทุกขนาดจอ: breakpoint mobile < 600 / tablet < 1024 / desktop, จอกว้างกว่า 1440 ขยายทั้งแอปตามสัดส่วนด้วย `ScreenScaler` (สูงสุด 2 เท่า) + กฎใน skill `simple-code` และ `docs/ARCHITECTURE.md` หัวข้อ 8 | ใช้ `fvm flutter` (global flutter 3.29 ทำ `pubspec.lock` ถอยเวอร์ชัน), analyze / test 18 ผ่าน |
| 2026-10-31 | `flutter create` + สร้างโฟลเดอร์ตาม `docs/ARCHITECTURE.md`, เพิ่มฟอนต์ LINESeedSansTH (5 น้ำหนัก) และ theme ใน `lib/core/theme/` (`AppColors`, `AppSizes`, `AppTheme`) + test | ย้าย `app_colors` / `app_sizes` จาก `constants/` ไป `theme/`, ลบ test counter ของ flutter create, analyze / test / build web ผ่าน |
| 2026-10-31 | เพิ่มวิธีต่อ API ใน `docs/ARCHITECTURE.md` (baseUrl หัวข้อ 1, error code → `.tr` หัวข้อ 10) | ตามกติกาของ `../api-Costbook` |
| 2026-10-31 | เพิ่มกฎ "หน้าโค้ดเยอะ → แยกส่วนย่อยเป็น extension ในไฟล์ `<ชื่อหน้า>_ext.dart`" ใน skill `simple-code` และ `docs/ARCHITECTURE.md` (หัวข้อ 3, 8, 13) | แก้แค่เอกสาร ทดลองแบบ `part` + extension ในโปรเจกต์ชั่วคราวแล้ว analyze ผ่าน |
| 2026-10-31 | เพิ่มกฎ "โค้ดที่ใช้ตั้งแต่ 2 จุด → แยกเป็นฟังก์ชันกลาง" ใน skill `simple-code` และ `docs/ARCHITECTURE.md` หัวข้อ 9 | แก้แค่เอกสาร ไม่มีโค้ด Dart |
| 2026-10-31 | สร้าง `docs/ARCHITECTURE.md`, `CLAUDE.md`, `PROGRESS.md`, skill `simple-code` และ `unit-test-check` | ยังไม่มีโค้ด Flutter |
