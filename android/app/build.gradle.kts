import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// D18/M17 bug #7: the release build was always signed with the debug key,
// meaning a rebuild on a different machine produced a differently-signed
// APK and forced every friend who'd already installed it to fully
// uninstall (losing their local-only data, since there's no cloud backup)
// before they could install the update. Real signing credentials live in
// `android/key.properties` (git-ignored, see `.gitignore` + the template at
// `android/key.properties.example`) — generated once per
// `docs/RELEASE.md` and never committed. When that file is absent (fresh
// clone, CI without secrets, local `flutter run --release` during dev)
// this deliberately falls back to the debug key so those workflows keep
// working, but prints a loud warning so that fallback is never silently
// mistaken for a real signed release build.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    logger.warn(
        "WARNING: android/key.properties not found — release build will " +
        "fall back to the DEBUG signing key. This is fine for local " +
        "`flutter run --release`, but a release APK built this way MUST " +
        "NOT be distributed (it breaks update continuity for anyone who " +
        "already installed a properly-signed build). See docs/RELEASE.md."
    )
}

android {
    namespace = "com.ledgermate.ledgermate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by the flutter_local_notifications dependency (FR-11) —
        // without this, `:app:checkDebugAarMetadata` fails the build with
        // "requires core library desugaring to be enabled". Pre-existing
        // gap from M0 (flutter_local_notifications was added to pubspec.yaml
        // there, but this Gradle flag was never set, so no `flutter build`
        // had actually been run against it until this M2 verification step
        // surfaced it) — flagged separately per AGENTS.md, fixed here only
        // because it blocks building/verifying M2's own UI work.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ledgermate.ledgermate"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // See the logger.warn(...) above — dev-only fallback, never
                // for a build that will actually be distributed.
                signingConfigs.getByName("debug")
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
    // Required alongside isCoreLibraryDesugaringEnabled above.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
