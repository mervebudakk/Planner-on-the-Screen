plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aesthetic.planner.aesthetic_planner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
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
            //
            // Şimdilik CI/CD ortamında environment variable ile imzalanacak.
            // Debug key ile Play Store yayını YAPMAYIN.
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

flutter {
    source = "../.."
}
