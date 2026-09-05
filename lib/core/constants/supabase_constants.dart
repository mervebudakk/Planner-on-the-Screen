/// ⚡ Calenda — Supabase Yapılandırma ve API Sabitleri
class SupabaseConstants {
  SupabaseConstants._();

  /// 🌐 Supabase Proje URL'niz
  /// (Supabase Dashboard -> Project Settings -> API -> Project URL)
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  /// 🔑 Supabase Anon / Public Key
  /// (Supabase Dashboard -> Project Settings -> API -> Project API keys -> anon public)
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Supabase yapılandırmasının girilip girilmediğini kontrol eder
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('YOUR_SUPABASE_URL') &&
        !supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY') &&
        supabaseUrl.startsWith('https://');
  }
}
