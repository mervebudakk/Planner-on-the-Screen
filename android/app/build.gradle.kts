plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aesthetic.planner.aesthetic_planner"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications için desugaring desteği
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.aesthetic.planner.aesthetic_planner"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        // 🔒 GÜVENLİK: Release build — R8 full mode + kod küçültme + kaynak küçültme
        release {
            // TODO: Gerçek production'da aşağıdaki signing config'i aktif edin:
            // signingConfig = signingConfigs.getByName("release")
            signingConfig = signingConfigs.getByName("debug") // Geliştirme aşaması

            // 🔒 GÜVENLİK: R8 minification + kod gizleme (reverse engineering zorlaştırır)
            isMinifyEnabled = true
            // 🔒 GÜVENLİK: Kullanılmayan kaynakları kaldır (saldırı yüzeyini azaltır)
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            applicationIdSuffix = ".debug"
        }
    }
}

dependencies {
    // Android desugaring kütüphanesi (Java 8/17 saat ve tarih API desteği)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
