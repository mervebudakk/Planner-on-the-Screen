import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:aesthetic_planner/core/models/user_profile.dart';
import 'package:aesthetic_planner/core/services/supabase_service.dart';

void main() {
  group('Auth & Profile Validation Logic Tests', () {
    test('UUID format validation works correctly', () {
      expect(SupabaseService.isValidUuid('00000000-0000-0000-0000-000000000001'), isTrue);
      expect(SupabaseService.isValidUuid('ccf0f1b6-40a0-405d-904a-8e6a8b3137d8'), isTrue);
      expect(SupabaseService.isValidUuid('usr_1790790991026'), isFalse);
      expect(SupabaseService.isValidUuid('google_1029384756'), isFalse);
      expect(SupabaseService.isValidUuid(''), isFalse);
      expect(SupabaseService.isValidUuid('guest'), isFalse);
    });

    test('Deterministic UUID v5 generates consistent valid UUIDs for same identifier', () {
      const googleId = '102938475628491';
      final uuid1 = const Uuid().v5(Namespace.url.value, 'calenda:google:$googleId');
      final uuid2 = const Uuid().v5(Namespace.url.value, 'calenda:google:$googleId');

      expect(uuid1, equals(uuid2));
      expect(SupabaseService.isValidUuid(uuid1), isTrue);
    });

    test('Username character validation rejects invalid formats and accepts valid ones', () {
      final validRegex = RegExp(r'^[a-zA-Z0-9_]+$');

      expect(validRegex.hasMatch('merome'), isTrue);
      expect(validRegex.hasMatch('merome_813'), isTrue);
      expect(validRegex.hasMatch('merome 813'), isFalse);
      expect(validRegex.hasMatch('merome@813'), isFalse);
      expect(validRegex.hasMatch('merome.813'), isFalse);
    });

    test('UserProfile copyWith preserves or updates fields properly', () {
      final profile = UserProfile(
        id: '00000000-0000-0000-0000-000000000001',
        username: 'merome',
        firstName: 'Merve',
        lastName: 'Öztürk',
        email: 'merome@example.com',
        avatarAnimal: 'rabbit',
        avatarAccessory: 'none',
        avatarBgColor: '#FAF7F2',
        isLoggedIn: true,
      );

      final updated = profile.copyWith(email: 'newemail@example.com');
      expect(updated.id, equals(profile.id));
      expect(updated.username, equals('merome'));
      expect(updated.email, equals('newemail@example.com'));
      expect(updated.isLoggedIn, isTrue);
    });
  });
}
