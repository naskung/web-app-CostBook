// ใช้ตอนไม่ได้รันบน browser (flutter test) — ทำเหมือนไม่มีอะไรให้ติดตั้ง
bool isInstalled() => false;

bool canPrompt() => false;

Future<bool> prompt() async => false;

String browserName() => '';

void setIcons(String faviconUrl, String appleIconUrl) {}
