plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.vecigest"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Mantener esta versión específica de NDK

    // Suprimir advertencias de deprecación de Convention
    @Suppress("DEPRECATION")
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Habilitar desugaring para compatibilidad con características de Java 8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            // IMPORTANT: You need to create a keystore file and configure these properties.
            // For example, you can store them in a keystore.properties file and load them here.
            // keyAlias = System.getenv("KEY_ALIAS") ?: "your_key_alias"
            // keyPassword = System.getenv("KEY_PASSWORD") ?: "your_key_password"
            // storeFile = System.getenv("STORE_FILE")?.let { project.file(it) } ?: project.file("your_keystore.jks")
            // storePassword = System.getenv("STORE_PASSWORD") ?: "your_store_password"
        }
    }

    defaultConfig {
        applicationId = "com.example.vecigest"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Agregar configuración para evitar problemas de compilación
        ndk {
            // Especificar las arquitecturas ABI compatibles
            abiFilters.clear() // Clear existing filters
            abiFilters.add("arm64-v8a")
            abiFilters.add("x86_64") // For emulators
        }
    }

    buildTypes {
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug") // Temporarily keeping debug for now, but this MUST be changed for actual releases
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// Añadir la dependencia de desugaring
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // Reverted to 2.1.4 and ensured it's coreLibraryDesugaring
    // Dependencias para Jetpack WindowManager
    implementation("androidx.window:window:1.2.0")
    implementation("androidx.window:window-java:1.2.0")
}

apply(plugin = "com.google.gms.google-services") // Firebase plugin
