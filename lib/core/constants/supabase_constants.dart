/// ⚡ Calenda — Supabase Yapılandırma ve API Sabitleri
class SupabaseConstants {
  SupabaseConstants._();

  /// 🌐 Supabase Proje URL'niz
  /// (Supabase Dashboard -> Project Settings -> API -> Project URL)
  static const String supabaseUrl = 'https://dcepxjedxoejdtduwtol.supabase.co';

  /// 🔑 Supabase Anon / Public Key
  /// (Supabase Dashboard -> Project Settings -> API -> Project API keys -> anon public)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZXB4amVkeG9lamR0ZHV3dG9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg1OTE2ODAsImV4cCI6MjEwNDE2NzY4MH0.HpPfGBNiCJ7rJX2WK023yGxfq8jeyneZfKOxatpwEuk';

  /// Supabase yapılandırmasının girilip girilmediğini kontrol eder
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE_URL') &&
        !supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY') &&
        supabaseUrl.startsWith('https://');
  }
}
