#!/bin/bash
set -euo pipefail

APP_PATH="/Users/admin/Documents/VSC/swift/Shifr/Shifr 2025-11-13 13-34-10/Shifr.app"
INFO_PLIST="$APP_PATH/Contents/Info.plist"
APP_NAME="$(basename "$APP_PATH" .app)"

# получить версию (CFBundleShortVersionString или CFBundleVersion)
if [ -f "$INFO_PLIST" ]; then
  VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$INFO_PLIST" 2>/dev/null || true)
  if [ -z "$VERSION" ]; then
    VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST" 2>/dev/null || true)
  fi
fi
VERSION=${VERSION:-"0.0.0"}
# очистка пробелов в имени файла
VERSION_SAFE=$(echo "$VERSION" | tr ' ' '_')

DMG_NAME="${APP_NAME}-${VERSION_SAFE}.dmg"
VOLUME_NAME="${APP_NAME}"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "App: $APP_PATH"
echo "Version: $VERSION"
echo "Output: $DMG_NAME"

# опциональная проверка подписи
if codesign --verify --deep --strict --verbose=2 "$APP_PATH" >/dev/null 2>&1; then
  echo "codesign: OK"
else
  echo "codesign: отсутствует или не прошла проверка"
fi

# подготовка содержимого для DMG
cp -R "$APP_PATH" "$TMPDIR/"
ln -s /Applications "$TMPDIR/Applications"

# создание сжатого DMG
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TMPDIR" -ov -format UDZO "$DMG_NAME"

echo "Готово: $DMG_NAME"
spctl -a -t open --context context:primary-signature "$DMG_NAME" || true