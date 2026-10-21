#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

ENVIRONMENT="${1:-prod}"
case "$ENVIRONMENT" in
  dev|prod)
    CONFIG_FILE="config/env.${ENVIRONMENT}.json"
    ;;
  *)
    printf 'Usage: %s [dev|prod]\n' "$0" >&2
    exit 2
    ;;
esac

if ! command -v flutter >/dev/null 2>&1; then
  printf 'Error: Flutter is not installed or is not available on PATH.\n' >&2
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'Error: configuration file not found: %s\n' "$CONFIG_FILE" >&2
  exit 1
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'Error: Building an iOS IPA requires macOS and Xcode.\n' >&2
  exit 1
fi

if [[ ! -f "android/key.properties" ]]; then
  printf 'Error: android/key.properties is required for signed Android release builds.\n' >&2
  exit 1
fi

printf 'Building signed release artifacts with %s configuration\n' "$ENVIRONMENT"

flutter build appbundle \
  --release \
  --dart-define-from-file="$CONFIG_FILE"

flutter build apk \
  --release \
  --dart-define-from-file="$CONFIG_FILE"

flutter build ipa \
  --release \
  --dart-define-from-file="$CONFIG_FILE"

printf '\nBuilds completed:\n'
printf '  App Bundle: build/app/outputs/bundle/release/app-release.aab\n'
printf '  APK:        build/app/outputs/flutter-apk/app-release.apk\n'
printf '  IPA:        build/ios/ipa/*.ipa\n'
