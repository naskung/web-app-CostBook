# Web-CostBook-

เว็บแอป (Flutter Web) สำหรับคำนวณต้นทุนสินค้า ออกใบกำกับภาษี บันทึกรายรับ-รายจ่าย และเช็ค stock
ต้องเปิด API ([../api-Costbook](../api-Costbook)) ไว้ก่อน — `cd ../api-Costbook && make run`

## คำสั่งที่ใช้บ่อย

โปรเจกต์นี้ใช้ Flutter ผ่าน **fvm** → พิมพ์ `fvm flutter ...` / `fvm dart ...` เสมอ

```bash
fvm flutter pub get                          # โหลด package (ครั้งแรก / หลังแก้ pubspec.yaml)
fvm flutter run -d chrome                    # เปิดแอปใน Chrome (เรียก API ที่ http://localhost:8080)
fvm flutter analyze                          # ตรวจโค้ด
fvm flutter test                             # รัน test ทั้งหมด
fvm dart format --line-length 120 lib test   # จัดรูปแบบโค้ด
fvm flutter build web                        # build เว็บ ได้ไฟล์ที่ build/web
```

เว็บต้องรู้ที่อยู่ API **ตอน build** (ฝังไว้ในไฟล์) — API อยู่ที่อื่นที่ไม่ใช่ `localhost:8080`:

```bash
fvm flutter build web --dart-define=API_URL=https://api.ตัวอย่าง.com/api/v1
```

## ให้เพื่อนลองเล่นผ่านเน็ต (ลิงก์ชั่วคราว)

เปิด API (`make run`) ค้างไว้ แล้วในอีกหน้าต่าง:

```bash
cd ~/Documents/GitHub/costbook && caffeinate -i ./share-with-friend.sh
```

ได้ลิงก์ `https://xxx.trycloudflare.com` ส่งให้เพื่อน / เลิกเล่นกด Ctrl+C — รายละเอียดดู [../README.md](../README.md)

## เอกสาร

- โครงสร้างและกติกา: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- ความคืบหน้า (ทำอะไรไปแล้ว): [PROGRESS.md](PROGRESS.md)
- กฎสำหรับ Claude: [CLAUDE.md](CLAUDE.md)
- Skills: [simple-code](.claude/skills/simple-code/SKILL.md), [unit-test-check](.claude/skills/unit-test-check/SKILL.md)
