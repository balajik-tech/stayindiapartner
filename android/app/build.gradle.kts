import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

configurations.all {
    exclude(group = "com.google.firebase", module = "firebase-iid")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}
val releaseSigningPropertyNames = listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
val hasReleaseSigningProperties = keystorePropertiesFile.isFile &&
    releaseSigningPropertyNames.all { !keystoreProperties.getProperty(it).isNullOrBlank() }

val validateReleaseSigning by tasks.registering {
    doLast {
        if (!keystorePropertiesFile.isFile) {
            throw GradleException("Missing android/key.properties required for release signing.")
        }

        val missingProperties = releaseSigningPropertyNames.filter {
            keystoreProperties.getProperty(it).isNullOrBlank()
        }
        if (missingProperties.isNotEmpty()) {
            throw GradleException(
                "Missing ${missingProperties.joinToString()} in android/key.properties."
            )
        }

        val storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
        if (!storeFile.isFile) {
            throw GradleException("Keystore file configured in android/key.properties was not found.")
        }
    }
}

tasks.configureEach {
    if (name == "bundleRelease" || name == "assembleRelease") {
        dependsOn(validateReleaseSigning)
    }
}

android {
    namespace = "com.stayindia.stayindiaowner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }


    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.stayindia.stayindiaowner"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigningProperties) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigningProperties) {
                signingConfig = signingConfigs.getByName("release")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.android.gms:play-services-auth:21.2.0")
}
