import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = 'id';

  String get language => _language;

  bool get isEnglish => _language == 'en';

  void changeLanguage(String language) {
    if (_language == language) return;

    _language = language;
    notifyListeners();
  }

  String text({
    required String id,
    required String en,
  }) {
    return isEnglish ? en : id;
  }
}