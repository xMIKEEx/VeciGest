plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin debe ir después de los anteriores
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.vecigest"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    @Suppress("DEPRECATION")
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            // Para producción, configura tu keystore seguro aquí
            // keyAlias = System.getenv("KEY_ALIAS") ?: "your_key_alias"
            // keyPassword = System.getenv("KEY_PASSWORD") ?: "your_key_password"
            // storeFile = System.getenv("STORE_FILE")?.let { project.file(it) } ?: project.file("your_keystore.jks")
            // storePassword = System.getenv("STORE_PASSWORD") ?: "your_store_password"
        }
    }

    defaultConfig {
        applicationId = "com.example.vecigest"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // Permite multidex para apps grandes

        ndk {
            abiFilters.clear()
            abiFilters.add("arm64-v8a")
            abiFilters.add("x86_64") // Para emuladores
        }
    }

    buildTypes {
        getByName("release") {
            // Para producción, usa tu keystore seguro
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true // Activa R8/ProGuard
            isShrinkResources = true // Reduce tamaño del APK eliminando recursos no usados
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // Optimizaciones adicionales para R8
            isDebuggable = false
            isJniDebuggable = false
            isPseudoLocalesEnabled = false
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }

    // Habilita el cacheo de compilación para builds más rápidos
    buildFeatures {
        viewBinding = true
    }

    // Optimizaciones de empaquetado
    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/LICENSE*",
                "META-INF/NOTICE*",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.window:window:1.2.0")
    implementation("androidx.window:window-java:1.2.0")
    // Optimización multidex
    implementation("androidx.multidex:multidex:2.0.1")
}

apply(plugin = "com.google.gms.google-services") // Firebase plugin

// RECOMENDACIÓN: Para producción, configura tu keystore y signingConfig correctamente y elimina dependencias/comentarios innecesarios.
