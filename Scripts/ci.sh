#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
TAG=${1:?Usage: ci.sh RELEASE_TAG}
sh Scripts/toolchain.sh
sh Scripts/build.sh
sh Scripts/package.sh "$TAG"
