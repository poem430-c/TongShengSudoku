import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';

class LocaleService extends ChangeNotifier {
  LocaleService(this._prefs) {
    final saved = _prefs.getString(_key);
    if (saved == AppLanguage.traditionalChinese.code) {
      _language = AppLanguage.traditionalChinese;
    } else {
      _language = AppLanguage.english;
    }
  }

  static const _key = 'app_language';

  final SharedPreferences _prefs;
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;
  AppStrings get strings => AppStrings(_language);

  static Future<LocaleService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocaleService(prefs);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    await _prefs.setString(_key, language.code);
    notifyListeners();
  }

  Future<void> toggle() async {
    await setLanguage(
      _language == AppLanguage.english
          ? AppLanguage.traditionalChinese
          : AppLanguage.english,
    );
  }
}
