# APK Build Failure Audit Report

## Scope and commands run

- `flutter analyze` *(failed: Flutter CLI is not installed in this container)*
- `dart analyze` *(failed: Dart CLI is not installed in this container)*
- `./android/gradlew -p android assembleRelease` *(failed before build could start)*
- Manual review of Android, Dart, dependency, API, and CI workflow files.

## 1) Code errors or warnings

### Analyzer status

Because the container does not have Flutter/Dart installed, analyzer checks could not run:

- `flutter analyze` -> `bash: command not found: flutter`
- `dart analyze` -> `bash: command not found: dart`

### Manual static review observations

- No hardcoded HTTP URLs were found in Flutter source files under `lib/`; API traffic is routed via `ApiClient.baseUrl`, which reads `API_BASE_URL` from environment configuration.
- `ApiClient.baseUrl` throws a `StateError` when `API_BASE_URL` is missing. This would cause runtime API failures, but **not** APK compile failures.

## 2) Dependency / pubspec.yaml issues

- `pubspec.yaml` uses Dart SDK constraint `>=3.3.0 <4.0.0`, which is generally valid for modern Flutter stable releases.
- Declared packages are broadly consistent (e.g., `firebase_core` + `firebase_messaging` pair, `http`, `geolocator`, `permission_handler`, etc.).
- No direct dependency conflict can be proven without running `flutter pub get`/analyzers in an environment with Flutter installed.

## 3) AndroidManifest / Gradle settings audit

### Manifest permissions

- `android/app/src/main/AndroidManifest.xml` contains `INTERNET` permission.
- Debug and profile manifests also include `INTERNET` permission.

### Android/Gradle configuration

- App module is configured with modern toolchain values: Java 17, Kotlin JVM target 17, AGP 8.7.3, Gradle 8.10.2 wrapper properties.
- `minSdk = 23` is compatible with the listed plugins.

### Critical issue found

- `android/gradle/wrapper/gradle-wrapper.jar` is missing from the repository.
- Running `./android/gradlew -p android assembleRelease` fails with:
  - `Could not find or load main class org.gradle.wrapper.GradleWrapperMain`
  - `ClassNotFoundException: org.gradle.wrapper.GradleWrapperMain`

Without `gradle-wrapper.jar`, the Gradle wrapper cannot bootstrap, so Android builds fail before code compilation.

## 4) CI workflow audit and APK failure root cause

Workflow reviewed: `.github/workflows/flutter-build.yml`

### Workflow correctness

- Core steps are present: Java setup, Flutter setup, pub get, test, APK build, artifact upload.
- The workflow includes `flutter create --platforms=android,ios .`, which may regenerate native folders and can overwrite custom native changes. It is not usually needed in CI for an existing Flutter app.

### Root cause of APK failure

**Primary root cause:** missing `android/gradle/wrapper/gradle-wrapper.jar` in repo.

This prevents `gradlew` from starting in both local and CI contexts, causing APK build failure irrespective of Dart/Flutter source validity.

### Recommended fixes

1. Restore and commit `android/gradle/wrapper/gradle-wrapper.jar` (standard Flutter/Gradle wrapper file).
2. Verify the wrapper by running:
   - `./android/gradlew -p android --version`
   - `flutter build apk --release`
3. In CI, consider removing `flutter create --platforms=android,ios .` unless intentionally regenerating native projects.
4. Add a quick CI guard step before build:
   - `test -f android/gradle/wrapper/gradle-wrapper.jar`
5. Run `flutter analyze` and `dart analyze` in an environment that has Flutter/Dart installed to catch any remaining code issues.

## Files inspected

- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/debug/AndroidManifest.xml`
- `android/app/src/profile/AndroidManifest.xml`
- `android/app/build.gradle`
- `android/build.gradle`
- `android/settings.gradle`
- `android/gradle/wrapper/gradle-wrapper.properties`
- `lib/services/api_client.dart`
- `lib/main.dart`
- `.github/workflows/flutter-build.yml`
