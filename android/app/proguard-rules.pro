# ============================================================
# Aesthetic Planner — ProGuard / R8 Kuralları
# ============================================================
#
# 🔒 GÜVENLİK: Bu dosya release build'de R8 full mode ile çalışır.
# Dart kodu --obfuscate ile ayrıca obfuscate edilir.
# Bu kurallar yalnızca Android (Kotlin/Java) kodu için geçerlidir.
# ============================================================

# Flutter engine sınıflarını koru
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# home_widget plugin sınıflarını koru
-keep class es.antonborri.home_widget.** { *; }

# Android AppWidgetProvider ve BroadcastReceiver koru
-keep public class * extends android.appwidget.AppWidgetProvider { *; }
-keep public class * extends android.content.BroadcastReceiver { *; }

# MainActivity'yi koru (Flutter embedding)
-keep class com.aesthetic.planner.aesthetic_planner.MainActivity { *; }

# Kotlin metadata koru
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# Gereksiz log ifadelerini production'da kaldır
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
}

# Flutter deferred components & Play Core warnings
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.**
-dontwarn com.google.**

# R8 full mode: Agresif küçültme ve gizleme
-allowaccessmodification
-repackageclasses ''
