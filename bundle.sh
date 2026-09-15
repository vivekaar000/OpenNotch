#!/bin/bash
set -e

APP_NAME="OpenNotch"
BUILD_DIR=".build/release"
APP_DIR="$APP_NAME.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RESOURCES_DIR="$APP_DIR/Contents/Resources"

echo "Building release binary..."
swift build -c release

echo "Creating .app bundle..."
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

cat << 'EOF' > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>OpenNotch</string>
    <key>CFBundleIdentifier</key>
    <string>com.opennotch.OpenNotch</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>OpenNotch</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>OpenNotch needs permission to control media playback for Apple Music and Spotify.</string>
</dict>
</plist>
EOF

echo "Ad-hoc signing application bundle..."
codesign --force --deep --sign - "$APP_DIR"

echo "OpenNotch.app created successfully!"
