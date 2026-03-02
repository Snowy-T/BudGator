#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Budgator"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must run on macOS (Xcode required for iOS builds)."
  exit 1
fi

echo "Fetching dependencies..."
flutter pub get

echo "Building iOS app (no code signing)..."
flutter build ios --release --no-codesign

BUILD_DIR="$ROOT_DIR/build/ios/iphoneos"
APP_PATH="$BUILD_DIR/Runner.app"
PAYLOAD_DIR="$BUILD_DIR/Payload"
IPA_PATH="$BUILD_DIR/${APP_NAME}.ipa"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle not found at: $APP_PATH"
  exit 1
fi

rm -rf "$PAYLOAD_DIR" "$IPA_PATH"
mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/"

echo "Packaging IPA..."
cd "$BUILD_DIR"
zip -qry "$IPA_PATH" Payload
rm -rf Payload

echo "IPA created: $IPA_PATH"
*** End Patch