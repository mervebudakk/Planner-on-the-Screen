import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import 'error_logger.dart';
import 'supabase_service.dart';

/// 🔐 Calenda Kimlik ve Google / Supabase Giriş Servisi
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '370278241179-a55s01st5clcspq2e5cc83paq2j4t57r.apps.googleusercontent.com'
        : (defaultTargetPlatform == TargetPlatform.iOS
            ? '370278241179-2c5t1q3mmhpa4bhq4jk3mlleg1onolcr.apps.googleusercontent.com'
            : null),
    serverClientId: kIsWeb
        ? null
        : '370278241179-a55s01st5clcspq2e5cc83paq2j4t57r.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  /// Google ile Giriş Yapar ve Supabase ile Senkronize Eder
  Future<UserProfile?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // Kullanıcı giriş ekranını iptal etti
        return null;
      }

      final String fullName = account.displayName?.trim().isNotEmpty == true
          ? account.displayName!.trim()
          : (account.email.split('@').first);

      final parts = fullName.split(' ');
      final String firstName = parts.isNotEmpty ? parts.first : fullName;
      final String lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final String defaultUsername = account.email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

      String userId = account.id.isNotEmpty ? account.id : const Uuid().v4();

      // Supabase ile kimlik doğrulama köprüsü (Eğer yapılandırılmışsa)
      try {
        final googleAuth = await account.authentication;
        if (googleAuth.idToken != null) {
          final authRes = await SupabaseService.instance.signInWithGoogleIdToken(
            idToken: googleAuth.idToken!,
            accessToken: googleAuth.accessToken,
          );
          if (authRes?.user != null) {
            userId = authRes!.user!.id;
          }
        }
      } catch (e, st) {
        ErrorLogger.log('AuthService.supabaseAuthBridge', e, st);
      }

      // 🔍 Mevcut bulut profilini kontrol et (Mevcut kullanıcının verilerini koru!)
      final existingProfile = await SupabaseService.instance.fetchUserProfile(userId);
      if (existingProfile != null && existingProfile.username.isNotEmpty) {
        final merged = existingProfile.copyWith(
          isLoggedIn: true,
          email: account.email.isNotEmpty ? account.email : existingProfile.email,
        );
        return merged;
      }

      final profile = UserProfile(
        id: userId,
        username: defaultUsername,
        firstName: firstName,
        lastName: lastName,
        email: account.email,
        avatarAnimal: '01_rabbit',
        avatarAccessory: 'none',
        avatarBgColor: '#FAF7F2',
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );

      // Yeni profil verisini buluta gönder
      await SupabaseService.instance.syncUserProfile(profile);

      return profile;
    } catch (e, st) {
      ErrorLogger.log('AuthService.signInWithGoogle', e, st);
      rethrow;
    }
  }

  /// Apple ile Giriş Yapar ve Supabase ile Senkronize Eder
  Future<UserProfile?> signInWithApple() async {
    try {
      final rawNonce = SupabaseService.instance.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Apple kimlik belirteci alınamadı.');
      }

      String userId = credential.userIdentifier ?? const Uuid().v4();

      // Supabase ile kimlik doğrulama köprüsü
      try {
        final authRes = await SupabaseService.instance.signInWithAppleIdToken(
          idToken: idToken,
          rawNonce: rawNonce,
        );
        if (authRes?.user != null) {
          userId = authRes!.user!.id;
        }
      } catch (e, st) {
        ErrorLogger.log('AuthService.signInWithApple.supabaseAuthBridge', e, st);
      }

      final String defaultEmail = credential.email ?? 'apple_${userId.substring(0, 8)}@calenda.internal';

      // 🔍 Mevcut bulut profilini kontrol et
      final existingProfile = await SupabaseService.instance.fetchUserProfile(userId);
      if (existingProfile != null && existingProfile.username.isNotEmpty) {
        final merged = existingProfile.copyWith(
          isLoggedIn: true,
          email: credential.email != null && credential.email!.isNotEmpty
              ? credential.email!
              : existingProfile.email,
        );
        return merged;
      }

      final String firstName = credential.givenName?.trim().isNotEmpty == true
          ? credential.givenName!.trim()
          : 'Calenda';
      final String lastName = credential.familyName?.trim().isNotEmpty == true
          ? credential.familyName!.trim()
          : '';
      final String defaultUsername = defaultEmail.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

      final profile = UserProfile(
        id: userId,
        username: defaultUsername.isNotEmpty ? defaultUsername : 'apple_user',
        firstName: firstName,
        lastName: lastName,
        email: defaultEmail,
        avatarAnimal: '01_rabbit',
        avatarAccessory: 'none',
        avatarBgColor: '#FAF7F2',
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );

      // Profil verisini buluta gönder
      await SupabaseService.instance.syncUserProfile(profile);

      return profile;
    } catch (e, st) {
      ErrorLogger.log('AuthService.signInWithApple', e, st);
      rethrow;
    }
  }

  /// E-posta ve Şifre ile Giriş Yapar
  Future<UserProfile?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final authRes = await SupabaseService.instance.signInWithPassword(
        email: email,
        password: password,
      );
      if (authRes?.user == null) {
        throw Exception('Giriş yapılamadı. Lütfen e-posta ve şifrenizi kontrol edin.');
      }

      final userId = authRes!.user!.id;
      final existingProfile = await SupabaseService.instance.fetchUserProfile(userId);

      if (existingProfile != null && existingProfile.username.isNotEmpty) {
        return existingProfile.copyWith(isLoggedIn: true, email: email.trim());
      }

      final username = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      final profile = UserProfile(
        id: userId,
        username: username,
        firstName: username,
        lastName: '',
        email: email.trim(),
        avatarAnimal: '01_rabbit',
        avatarAccessory: 'none',
        avatarBgColor: '#FAF7F2',
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );
      await SupabaseService.instance.syncUserProfile(profile);
      return profile;
    } catch (e, st) {
      ErrorLogger.log('AuthService.signInWithEmail', e, st);
      rethrow;
    }
  }

  /// E-posta ve Şifre ile Yeni Kayıt Oluşturur
  Future<UserProfile?> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? username,
  }) async {
    try {
      final authRes = await SupabaseService.instance.signUpWithEmail(
        email: email,
        password: password,
      );
      if (authRes?.user == null) {
        throw Exception('Kayıt oluşturulamadı. Lütfen tekrar deneyin.');
      }

      final userId = authRes!.user!.id;
      final defaultUsername = username?.trim().isNotEmpty == true
          ? username!.trim()
          : email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

      final profile = UserProfile(
        id: userId,
        username: defaultUsername,
        firstName: firstName?.trim().isNotEmpty == true ? firstName!.trim() : 'Kullanıcı',
        lastName: lastName?.trim() ?? '',
        email: email.trim(),
        avatarAnimal: '01_rabbit',
        avatarAccessory: 'none',
        avatarBgColor: '#FAF7F2',
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );

      await SupabaseService.instance.syncUserProfile(profile);
      return profile;
    } catch (e, st) {
      ErrorLogger.log('AuthService.signUpWithEmail', e, st);
      rethrow;
    }
  }

  /// Oturumu Kapatır
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await SupabaseService.instance.signOut();
    } catch (e, st) {
      ErrorLogger.log('AuthService.signOut', e, st);
    }
  }

  /// Kullanıcı hesabını ve bağlı tüm bulut verilerini kalıcı olarak siler
  Future<bool> deleteAccount() async {
    try {
      await SupabaseService.instance.deleteUserAccountAndData();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      await signOut();
      return true;
    } catch (e, st) {
      ErrorLogger.log('AuthService.deleteAccount', e, st);
      return false;
    }
  }
}
