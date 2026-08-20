# 🗓️ Aesthetic Planner (Planner on the Screen)

> **Minimalist, şeffaf ana ekran & kilit ekranı widget destekli haftalık ders ve ajanda uygulaması.**

Flutter ile geliştirilmiş, offline-first mimariye sahip, şık ve modern bir haftalık planlayıcı.

---

## ✨ Özellikler

- **📱 Şeffaf Ana Ekran Widget'ı (Android):** Duvar kağıdınızı kapatmayan, %100 şeffaflık ayarlı ve metin gölgesi korumalı canlı widget.
- **📅 7 Günlük Mini Haftalık Çizelge (Weekly Grid):** Referans tasarıma uygun, günlere göre renkli etkinlik çipleri.
- **⏱️ Günlük Zaman Akışı (Daily Agenda / Timeline):** Seçilen günün etkinliklerini şık renkli dikey göstergelerle listeleme.
- **🎨 Aesthetic Pastel & Neon Renk Paleti:** Seçilebilir pastel renkler ve canlı önizleme desteği.
- **🔔 Akıllı Yerel Bildirimler:** Her etkinliğe özel açılıp kapanabilir, ders başlamadan X dakika önce hatırlatan yerel alarm motoru (`flutter_local_notifications`).
- **🛡️ OWASP Standartlarında Güvenlik:** 
  - `android:allowBackup="false"` ile ADB veri sızıntısı koruması
  - Güvenli `fromJson` veri sanitizasyonu ve `.clamp()` sınır doğrulaması
  - Kilit ekranında bildirim içeriği gizleme (`NotificationVisibility.private`)
  - FNV-1a 32-bit hash ile bildirim ID çakışması önleme
  - `flutter_secure_storage` (Android KeyStore & iOS Keychain) hazır altyapısı
  - R8 Full Mode kod küçültme ve gizleme (`proguard-rules.pro`)

---

## 🏗️ Mimari & Teknoloji Yığını

- **Framework:** Flutter 3.x (Dart 3.x)
- **State Management:** Provider (`ChangeNotifier`)
- **Local Persistence:** SharedPreferences (Offline-First) + FlutterSecureStorage
- **Widget Bridge:** `home_widget` (Flutter ↔ Native Kotlin AppWidget)
- **Bildirim Motoru:** `flutter_local_notifications` + `timezone`
- **Tipografi:** Google Fonts (`Inter`)

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.27+)
- [Android Studio](https://developer.android.com/studio) ve Android SDK

### Adımlar

1. **Bağımlılıkları Yükleyin:**
   ```bash
   flutter pub get
   ```

2. **Birim ve Güvenlik Testlerini Çalıştırın:**
   ```bash
   flutter test
   ```

3. **Uygulamayı Cihazda / Emülatörde Başlatın:**
   ```bash
   flutter run
   ```

---

## 🔒 Güvenlik Notları

Release build alırken kod gizlemeyi (obfuscation) aktif etmek için:

```bash
flutter build appbundle --obfuscate --split-debug-info=./build/app/outputs/symbols
```
