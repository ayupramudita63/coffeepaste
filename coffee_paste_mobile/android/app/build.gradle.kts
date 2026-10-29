plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Wajib ada agar push notification (FCM) bisa dibaca dari google-services.json.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.coffeepaste.coffee_paste"
    compileSdk = flutter.compileSdkVersion
    // NDK 27.0.12077973 di mesin ini rusak (folder build/ hilang), jadi pakai
    // NDK 26.3 yang terpasang lengkap. Kembalikan ke 27 bila NDK-nya diperbaiki.
    ndkVersion = "26.3.11579264"

    compileOptions {
        // flutter_local_notifications butuh desugaring (Java 8 API di Android lama).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.coffeepaste.coffee_paste"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // firebase_messaging mensyaratkan minSdk 24 (default Flutter 21 terlalu rendah).
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
