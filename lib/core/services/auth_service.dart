import 'package:google_sign_in/google_sign_in.dart';
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
    scopes: ['email', 'profile'],
    serverClientId: '370278241179-a55s01st5clcspq2e5cc83paq2j4t57r.apps.googleusercontent.com',
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

      // Profil verisini buluta gönder
      await SupabaseService.instance.syncUserProfile(profile);

      return profile;
    } catch (e, st) {
      ErrorLogger.log('AuthService.signInWithGoogle', e, st);
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
}
