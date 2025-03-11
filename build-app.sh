#!/bin/bash
# filepath: /Users/jacob/Projects/mouse-app/build-app.sh

# Exit on error
set -e

echo "Building Mouse Teleporter application..."

# Build the app in release mode
swift build --configuration release

# Define app bundle structure
APP_NAME="MouseTeleporter"
APP_DIR="$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
FRAMEWORKS_DIR="$CONTENTS_DIR/Frameworks"

# Create the directory structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
# Copy app icon
cp AppIcon.icns "$RESOURCES_DIR/"
mkdir -p "$FRAMEWORKS_DIR"

# Copy the built executable
cp .build/arm64-apple-macosx/release/MouseTeleporter "$MACOS_DIR/$APP_NAME"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>MouseTeleporter</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.cavas.MouseTeleporter</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Mouse Teleporter</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025. All rights reserved.</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

# Make the executable runnable
chmod +x "$MACOS_DIR/$APP_NAME"

echo "App bundle created at: $APP_DIR"
echo "You can now run the app by double-clicking it in Finder."
echo "To move it to your Applications folder, use:"
echo "  mv \"$APP_DIR\" /Applications/"