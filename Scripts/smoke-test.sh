#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
DEVICE=${1:?Usage: smoke-test.sh BOOTED_SIMULATOR_UDID}
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
ARCH=$(uname -m)
xcrun --sdk iphonesimulator clang -arch "$ARCH" -isysroot "$SDK" \
    -mios-simulator-version-min=15.0 \
    -I kivy-ios/dist/root/python3/include/python3.11 \
    Scripts/smoke-test.c -o artifacts/python-smoke \
    -L kivy-ios/dist/lib/iphonesimulator -lpython3.11 -lssl -lcrypto -lffi \
    -lz -lbz2 -lsqlite3 -framework Foundation
xcrun simctl spawn "$DEVICE" "$PWD/artifacts/python-smoke" "$PWD/Sources/PythonSupport"
