#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
KIVY_REVISION=fd363d49eddb5ac06766348738bd89c7d46007f8
if [ ! -d kivy-ios/.git ]; then
    git clone https://github.com/kivy/kivy-ios.git kivy-ios
fi
git -C kivy-ios checkout "$KIVY_REVISION"
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -e ./kivy-ios 'Cython==0.29.37'
# Pin both interpreters: the host interpreter generates target bytecode.
python Scripts/prepare-toolchain.py
cd kivy-ios
env -i HOME="$HOME" PATH="$PATH" TMPDIR="${TMPDIR:-/tmp}" \
    DEVELOPER_DIR="$(xcode-select -p)" \
    python toolchain.py build hostpython3 python3 \
    --platform iphoneos-arm64 \
    --platform iphonesimulator-arm64 \
    --platform iphonesimulator-x86_64 \
    --concurrency 8
