# stayindia_owner

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# Stay-India-Owner

## Build release artifacts

Run `./build_app.sh` to build the production IPA, Android App Bundle, and APK.
To build against the development configuration, run `./build_app.sh dev`.
The script defaults to `prod`; both commands use the matching
`config/env.<environment>.json` through Flutter's `--dart-define-from-file`.

Android release builds require `android/key.properties` and its configured
keystore. IPA builds require macOS, Xcode, and valid iOS signing setup.

These JSON files are compiled into the app and are not secure storage. Do not
put private credentials or secrets in them; use a backend for values that must
remain secret.
