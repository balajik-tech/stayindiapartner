#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

ENVIRONMENT="${1:-prod}"
ARTIFACT="${2:-all}"

# Select environment configuration
case "$ENVIRONMENT" in
  dev|prod)
    CONFIG_FILE="config/env.${ENVIRONMENT}.json"
    ;;
  *)
    printf 'Usage: %s [dev|prod] [ipa|appbundle|apk|all]\n' "$0" >&2
    exit 2
    ;;
esac

# Select build artifact
case "$ARTIFACT" in
  ipa|appbundle|apk|all)
    ;;
  *)
    printf 'Error: Invalid artifact: %s\n' "$ARTIFACT" >&2
    printf 'Available artifacts: ipa, appbundle, apk, all\n' >&2
    exit 2
    ;;
esac

# Verify Flutter installation
if ! command -v flutter >/dev/null 2>&1; then
  printf 'Error: Flutter is not installed or is not available on PATH.\n' >&2
  exit 1
fi

# Verify configuration file
if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'Error: Configuration file not found: %s\n' "$CONFIG_FILE" >&2
  exit 1
fi

# Verify macOS for IPA builds
if [[ "$ARTIFACT" == "ipa" || "$ARTIFACT" == "all" ]]; then
  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf 'Error: Building an iOS IPA requires macOS and Xcode.\n' >&2
    exit 1
  fi
fi

# Verify Android signing configuration for Android release builds
if [[ "$ARTIFACT" == "appbundle" || "$ARTIFACT" == "apk" || "$ARTIFACT" == "all" ]]; then
  if [[ ! -f "android/key.properties" ]]; then
    printf 'Error: android/key.properties is required for signed Android release builds.\n' >&2
    exit 1
  fi
fi

printf '\nEnvironment: %s\n' "$ENVIRONMENT"
printf 'Artifact:    %s\n\n' "$ARTIFACT"

# Clean previous build outputs before building
printf 'Cleaning previous build artifacts...\n'
flutter clean

# Build selected artifact(s)
case "$ARTIFACT" in
  ipa)
    flutter build ipa \
      --release \
      --dart-define-from-file="$CONFIG_FILE"
    ;;
  appbundle)
    flutter build appbundle \
      --release \
      --dart-define-from-file="$CONFIG_FILE"
    ;;
  apk)
    flutter build apk \
      --release \
      --dart-define-from-file="$CONFIG_FILE"
    ;;
  all)
    flutter build appbundle \
      --release \
      --dart-define-from-file="$CONFIG_FILE"

    flutter build apk \
      --release \
      --dart-define-from-file="$CONFIG_FILE"

    flutter build ipa \
      --release \
      --dart-define-from-file="$CONFIG_FILE"
    ;;
esac

printf '\nBuild completed successfully!\n'

case "$ARTIFACT" in
  ipa)
    printf 'IPA:        build/ios/ipa/*.ipa\n'
    ;;
  appbundle)
    printf 'App Bundle: build/app/outputs/bundle/release/app-release.aab\n'
    ;;
  apk)
    printf 'APK:        build/app/outputs/flutter-apk/app-release.apk\n'
    ;;
  all)
    printf 'App Bundle: build/app/outputs/bundle/release/app-release.aab\n'
    printf 'APK:        build/app/outputs/flutter-apk/app-release.apk\n'
    printf 'IPA:        build/ios/ipa/*.ipa\n'
    ;;
esac