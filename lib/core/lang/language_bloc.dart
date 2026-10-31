import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:costbook/core/lang/app_lang.dart';

class ChangeLanguage {
  ChangeLanguage(this.code);

  final String code;
}

class LanguageBloc extends Bloc<ChangeLanguage, String> {
  LanguageBloc() : super(AppLang.currentCode) {
    on<ChangeLanguage>(_onChangeLanguage);
  }

  static const String savedKey = 'lang';

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<String> emit) async {
    await AppLang.load(event.code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(savedKey, event.code);
    emit(event.code);
  }

  static Future<String> savedCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(savedKey) ?? 'th';
  }
}
