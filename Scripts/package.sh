#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
TAG=${1:?Usage: package.sh RELEASE_TAG}
export TAG
for name in libpython3 libssl libcrypto libffi; do
    rm -f "artifacts/$name.xcframework.zip"
    (cd artifacts && zip -qry "$name.xcframework.zip" "$name.xcframework")
done
python3 - <<'PY'
import hashlib
import os
from pathlib import Path

manifest = Path('Package.swift.in').read_text().replace('TAG', os.environ['TAG'])
for name in ('libpython3', 'libssl', 'libcrypto', 'libffi'):
    checksum = hashlib.sha256(Path(f'artifacts/{name}.xcframework.zip').read_bytes()).hexdigest()
    manifest = manifest.replace(f'{name}.xcframework_CHECKSUM', checksum)
Path('Package.swift').write_text(manifest)
PY
