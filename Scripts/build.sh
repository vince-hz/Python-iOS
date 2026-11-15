#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p artifacts
# Include headers on every slice so clients can use the CPython C API.
rm -rf artifacts/libpython3.xcframework
xcodebuild -create-xcframework -output artifacts/libpython3.xcframework \
    -library kivy-ios/dist/lib/iphoneos/libpython3.11.a \
    -headers kivy-ios/dist/root/python3/include/python3.11 \
    -library kivy-ios/dist/lib/iphonesimulator/libpython3.11.a \
    -headers kivy-ios/dist/root/python3/include/python3.11
for name in libssl libcrypto libffi; do
    rm -rf "artifacts/$name.xcframework"
    cp -R "kivy-ios/dist/xcframework/$name.xcframework" artifacts/
done
rm -rf Sources/PythonSupport/lib
cp -R kivy-ios/dist/root/python3/lib Sources/PythonSupport/lib
