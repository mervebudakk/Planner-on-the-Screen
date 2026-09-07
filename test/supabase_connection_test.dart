// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aesthetic_planner/core/constants/supabase_constants.dart';

void main() {
  test('Supabase Connection & Table Check', () async {
    expect(SupabaseConstants.isConfigured, isTrue);

    final client = SupabaseClient(
      SupabaseConstants.supabaseUrl,
      SupabaseConstants.supabaseAnonKey,
    );

    // 1. Tabloların varlığını sorgula (RLS açık olduğu için anonim sorgu boş liste veya 200 döner, hata vermez)
    try {
      final profilesRes = await client.from('profiles').select().limit(1);
      print('✅ profiles tablosu erişilebilir: $profilesRes');

      final eventsRes = await client.from('schedule_events').select().limit(1);
      print('✅ schedule_events tablosu erişilebilir: $eventsRes');

      final routinesRes = await client.from('routines').select().limit(1);
      print('✅ routines tablosu erişilebilir: $routinesRes');

      final focusRes = await client.from('focus_sessions').select().limit(1);
      print('✅ focus_sessions tablosu erişilebilir: $focusRes');

      final widgetRes = await client.from('widget_configs').select().limit(1);
      print('✅ widget_configs tablosu erişilebilir: $widgetRes');
    } catch (e) {
      print('❌ Tablo sorgulama hatası: $e');
      rethrow;
    }
  });
}
