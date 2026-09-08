import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// 🌐 Calenda — Dinamik Dil ve Yerelleştirme Yöneticisi
class LocaleProvider extends ChangeNotifier {
  final StorageService _storageService;
  late Locale _locale;

  LocaleProvider(this._storageService) {
    _initLocale();
  }

  Locale get locale => _locale;
  bool get isTurkish => _locale.languageCode == 'tr';
  bool get isEnglish => _locale.languageCode == 'en';

  /// İlk açılışta veya depolamadan dili başlatır
  void _initLocale() {
    final savedLang = _storageService.getSelectedLanguage();

    if (savedLang != null && (savedLang == 'tr' || savedLang == 'en')) {
      _locale = Locale(savedLang);
    } else {
      // 📱 Cihazın işletim sistemi varsayılan dilini algıla
      final deviceLanguageCode = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      
      // Eğer cihaz Türkçe ise Türkçe, aksi takdirde (İngilizce ve diğer tüm diller için) evrensel İngilizce
      final initialLang = deviceLanguageCode.startsWith('tr') ? 'tr' : 'en';
      _locale = Locale(initialLang);
      _storageService.setSelectedLanguage(initialLang);
    }
  }

  /// Dili dinamik olarak değiştirir ve yerel hafızaya kaydeder
  Future<void> setLanguage(String languageCode) async {
    if (languageCode != 'tr' && languageCode != 'en') return;
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);
    await _storageService.setSelectedLanguage(languageCode);
    notifyListeners();
  }
}
