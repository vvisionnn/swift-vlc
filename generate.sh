#!/bin/sh
#
rm -rf .tmp/ || true

# Check if required environment variables are set and not empty
if [ -z "${TAG_VERSION}" ]; then
  echo "Error: TAG_VERSION environment variable is not set"
  exit 1
fi

if [ -z "${IOS_URL}" ]; then
  echo "Error: IOS_URL environment variable is not set"
  exit 1
fi

if [ -z "${MACOS_URL}" ]; then
  echo "Error: MACOS_URL environment variable is not set"
  exit 1
fi

if [ -z "${TVOS_URL}" ]; then
  echo "Error: TVOS_URL environment variable is not set"
  exit 1
fi

mkdir .tmp/

#Download and generate MobileVLCKit
echo "Downloading MobileVLCKit..."
wget -q -O .tmp/MobileVLCKit.tar.xz $IOS_URL
echo "Extracting MobileVLCKit..."
tar -xf .tmp/MobileVLCKit.tar.xz -C .tmp/ 2>/dev/null

#Download and generate VLCKit
echo "Downloading VLCKit..."
wget -q -O .tmp/VLCKit.tar.xz $MACOS_URL
echo "Extracting VLCKit..."
tar -xf .tmp/VLCKit.tar.xz -C .tmp/ 2>/dev/null

#Download and generate TVVLCKit
echo "Downloading TVVLCKit..."
wget -q -O .tmp/TVVLCKit.tar.xz $TVOS_URL
echo "Extracting TVVLCKit..."
tar -xf .tmp/TVVLCKit.tar.xz -C .tmp/ 2>/dev/null

IOS_LOCATION=".tmp/MobileVLCKit-binary/MobileVLCKit.xcframework"
TVOS_LOCATION=".tmp/TVVLCKit-binary/TVVLCKit.xcframework"
MACOS_LOCATION=".tmp/VLCKit - binary package/VLCKit.xcframework"

#Merge into one xcframework
xcodebuild -create-xcframework \
  -framework "$MACOS_LOCATION/macos-arm64_x86_64/VLCKit.framework" \
  -debug-symbols "${PWD}/$MACOS_LOCATION/macos-arm64_x86_64/dSYMs/VLCKit.framework.dSYM" \
  -framework "$TVOS_LOCATION/tvos-arm64_x86_64-simulator/TVVLCKit.framework" \
  -debug-symbols "${PWD}/$TVOS_LOCATION/tvos-arm64_x86_64-simulator/dSYMs/TVVLCKit.framework.dSYM" \
  -framework "$TVOS_LOCATION/tvos-arm64/TVVLCKit.framework" \
  -debug-symbols "${PWD}/$TVOS_LOCATION/tvos-arm64/dSYMs/TVVLCKit.framework.dSYM" \
  -framework "$IOS_LOCATION/ios-arm64_i386_x86_64-simulator/MobileVLCKit.framework" \
  -debug-symbols "${PWD}/$IOS_LOCATION/ios-arm64_i386_x86_64-simulator/dSYMs/MobileVLCKit.framework.dSYM" \
  -framework "$IOS_LOCATION/ios-arm64_armv7_armv7s/MobileVLCKit.framework" \
  -debug-symbols "${PWD}/$IOS_LOCATION/ios-arm64_armv7_armv7s/dSYMs/MobileVLCKit.framework.dSYM" \
  -output .tmp/VLCKitFull.xcframework

ditto -c -k --sequesterRsrc --keepParent ".tmp/VLCKitFull.xcframework" ".tmp/VLCKitFull.xcframework.zip"

# Update package file
PACKAGE_HASH=$(shasum -a 256 ".tmp/VLCKitFull.xcframework.zip" | awk '{ print $1 }')
if [ -z "$PACKAGE_HASH" ]; then
  echo "Error: Failed to calculate the hash of the xcframework"
  exit 1
fi

# Update Package.swift with new checksum and URL
awk -v tag="$TAG_VERSION" -v hash="$PACKAGE_HASH" '
/\/\/ GENERATED_START/,/\/\/ GENERATED_END/ {
  if ($0 ~ /\/\/ GENERATED_START/) {
    print $0
    print "let vlcBinary = Target.binaryTarget("
    print "\tname: \"VLCKitFull\","
    print "\turl: \"https://github.com/vvisionnn/swift-vlc/releases/download/" tag "/VLCKitFull.xcframework.zip\","
    print "\tchecksum: \"" hash "\""
    print ")"
  } else if ($0 ~ /\/\/ GENERATED_END/) {
    print $0
  }
  next
}
{ print $0 }
' Package.swift >Package.swift.tmp && mv Package.swift.tmp Package.swift

cp -f .tmp/MobileVLCKit-binary/COPYING.txt ./LICENSE
