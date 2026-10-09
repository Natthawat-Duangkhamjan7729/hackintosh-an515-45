#!/bin/bash
# Build the prepared local source tree only. No download or installation.
set -euo pipefail
cd "$(dirname "$0")/source"
if [[ "$(uname -s)" != Darwin ]]; then
    echo 'Run this script on macOS with full Xcode installed.' >&2
    exit 1
fi
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
if [[ ! -x "$DEVELOPER_DIR/usr/bin/xcodebuild" ]]; then
    echo 'Install full Xcode at /Applications/Xcode.app first.' >&2
    exit 1
fi
output="$(mktemp -d "$PWD/offline-build.XXXXXX")"
{
    sw_vers
    uname -r
    xcodebuild -version
    xcodebuild -project SimpleMtkWlan.xcodeproj -scheme SimpleMtkWlan \
      -configuration Debug -derivedDataPath "$output/DerivedData" \
      ARCHS=x86_64 CODE_SIGNING_ALLOWED=NO \
      'KERNEL_FRAMEWORK_HEADERS=$(PROJECT_DIR)/MacKernelSDK/Headers' build
} 2>&1 | tee "$output/build.log"
echo "Build finished. Output: $output/DerivedData/Build/Products/Debug"
echo 'This does not install or load the kext. Hardware support remains unverified.'
