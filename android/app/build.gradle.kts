plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.bakalarka"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // 1. DEFINÍCIA PODPISOVANIA
    signingConfigs {
        create("release") {
            keyAlias = "moj-alias"
            keyPassword = "Mojasestra1@"
            storeFile = file("C:/Users/janas/moj-kluc.jks")
            storePassword = "Mojasestra1@"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.bakalarka"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 2. NASTAVENIE BUILDOV
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")

            // TOTO SÚ TIE DVA RIADKY, KTORÉ MUSIA BYŤ ROVNAKO (false/false)
            isMinifyEnabled = false
            isShrinkResources = false

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        getByName("debug") {
            // Tu to zvyčajne nie je nastavené, ale ak by bolo, daj tiež false
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    // Importuj Firebase BoM (Bill of Materials) - stará sa o verzie
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    // Pridaj knižnice pre Auth a Firestore
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}