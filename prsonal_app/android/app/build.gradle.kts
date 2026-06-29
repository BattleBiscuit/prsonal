import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is configured via android/key.properties (git-ignored).
// When that file is absent we must NOT fall back to the debug key for a
// release build: a debug-signed release has a different signature than a
// properly-signed one, so installing it over an existing install fails and
// forces an uninstall/reinstall — which wipes the user's local database
// (workout history included). So a release build with no keystore fails loudly
// instead. Debug builds (and CI without secrets) still build fine.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// True when a release artifact is actually being assembled (assembleRelease,
// bundleRelease, etc.). We only enforce the keystore in that case so that
// debug builds and `flutter run` are unaffected when key.properties is absent.
val isAssemblingRelease = gradle.startParameter.taskNames.any {
    it.contains("Release")
}

android {
    namespace = "com.prsonal.prsonal_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.prsonal.prsonal_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                hasReleaseKeystore -> signingConfigs.getByName("release")
                isAssemblingRelease -> throw GradleException(
                    "Cannot build a release: android/key.properties is missing, " +
                        "so no release signing keystore is available. Refusing to " +
                        "fall back to the debug key — a debug-signed release has a " +
                        "different signature and would force users to uninstall " +
                        "(wiping their local data) to update. Provide key.properties " +
                        "with the release keystore, then rebuild.",
                )
                // Not assembling a release (e.g. configuration for a debug build);
                // the value is unused but must be assignable.
                else -> signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
