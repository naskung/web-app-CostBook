import 'dart:js_interop';

// เรียกฟังก์ชันใน window.costbookWebApp (เขียนไว้ใน web/index.html)

@JS('costbookWebApp.isInstalled')
external bool _isInstalled();

@JS('costbookWebApp.canPrompt')
external bool _canPrompt();

@JS('costbookWebApp.prompt')
external JSPromise<JSBoolean> _prompt();

@JS('costbookWebApp.browser')
external String _browser();

@JS('costbookWebApp.setIcons')
external void _setIcons(String faviconUrl, String appleIconUrl);

bool isInstalled() => _isInstalled();

bool canPrompt() => _canPrompt();

Future<bool> prompt() async => (await _prompt().toDart).toDart;

String browserName() => _browser();

void setIcons(String faviconUrl, String appleIconUrl) => _setIcons(faviconUrl, appleIconUrl);
