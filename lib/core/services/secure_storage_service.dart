import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'error_logger.dart';

/// Kimlik bilgileri ve şifreleme anahtarları için güvenli depolama servisi.
///
/// Android → Android KeyStore (AES-GCM şifrelemeli)
/// iOS → iOS Keychain Services (Secure Enclave korumalı)
///
/// ⚠️  SADECE küçük ve hassas veriler için kullanın (token, şifreleme anahtarı, PIN hash).
/// Büyük veri setleri (etkinlik listesi) için [StorageService] kullanın.
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    // Android: Bozuk KeyStore durumunda otomatik sıfırla, algoritma değişiminde migrate et
    aOptions: AndroidOptions(
      resetOnError: true,
      encryptedSharedPreferences: true,
    ),
    // iOS: Yalnızca bu fiziksel cihazda erişilebilir, iCloud backup'a dahil edilmez
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  /// Güvenli depoya anahtar-değer yazar.
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      ErrorLogger.log('SecureStorageService.write', e, st, 'key=$key');
    }
  }

  /// Güvenli depodan değer okur; bulunamazsa `null` döner.
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, st) {
      ErrorLogger.log('SecureStorageService.read', e, st, 'key=$key');
      return null;
    }
  }

  /// Güvenli depodan belirli bir anahtarı siler.
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      ErrorLogger.log('SecureStorageService.delete', e, st, 'key=$key');
    }
  }

  /// Tüm güvenli depo içeriğini temizler (çıkış yapıldığında kullanılır).
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      ErrorLogger.log('SecureStorageService.deleteAll', e, st);
    }
  }

  /// Belirtilen anahtarın güvenli depoda var olup olmadığını kontrol eder.
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e, st) {
      ErrorLogger.log('SecureStorageService.containsKey', e, st, 'key=$key');
      return false;
    }
  }
}
