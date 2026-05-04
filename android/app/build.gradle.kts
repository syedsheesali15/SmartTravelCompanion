import java.util.Properties
import kotlin.math.max

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localMapsProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

android {
    namespace = "com.smarttravel.smart_travel_companion"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Maps SDK for Android requires API 24+ (google_maps_flutter_android).
        applicationId = "com.smarttravel.smart_travel_companion"
        minSdk = max(flutter.minSdkVersion, 24)
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
            localMapsProps.getProperty("GOOGLE_MAPS_API_KEY", "")
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
    // Required by flutter_local_notifications when using newer Android SDK / JDK APIs.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
