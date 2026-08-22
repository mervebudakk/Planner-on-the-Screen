import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import 'error_logger.dart';

/// 🔐 Calenda Kimlik ve Google Giriş Servisi
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '370278241179-a55s01st5clcspq2e5cc83paq2j4t57r.apps.googleusercontent.com',
  );

  /// Google ile Giriş Yapar
  Future<UserProfile?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // Kullanıcı giriş ekranını iptal etti
        return null;
      }

      final String displayName = account.displayName?.trim().isNotEmpty == true
          ? account.displayName!.trim()
          : (account.email.split('@').first);

      return UserProfile(
        id: account.id.isNotEmpty ? account.id : const Uuid().v4(),
        name: displayName,
        email: account.email,
        avatarUrl: account.photoUrl,
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );
    } catch (e, st) {
      ErrorLogger.log('AuthService.signInWithGoogle', e, st);
      rethrow;
    }
  }

  /// Oturumu Kapatır
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e, st) {
      ErrorLogger.log('AuthService.signOut', e, st);
    }
  }
}
