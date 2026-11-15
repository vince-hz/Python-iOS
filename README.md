# Python 3.11 for iOS

This fork of [kewlbear/Python-iOS](https://github.com/kewlbear/Python-iOS) packages CPython 3.11.18 as static XCFrameworks for Swift Package Manager. It supports iOS 15 or later, arm64 devices, and arm64/x86_64 simulators.

## Use

Add `https://github.com/vince-hz/Python-iOS.git` in Xcode and select the `Python-iOS` product. Pin the package to a tested commit. The package includes the matching standard library in `Python-iOS_PythonSupport.bundle`.

PythonKit can access the linked CPython symbols. Applications that initialize CPython themselves should use that resource bundle as Python home. Serialize initialization and hold the GIL while accessing Python objects. The legacy `PythonSupport.initialize()` helper replaces `subprocess`; applications with their own FFmpeg bridge should initialize CPython directly.

## Build

Requires Xcode, Python 3.11, and Homebrew build tools:

```sh
brew install autoconf automake libtool pkg-config
sh Scripts/ci.sh 3.11.18-1
```

The build pins kivy-ios to `fd363d49eddb5ac06766348738bd89c7d46007f8` and applies the small compatibility changes in `Scripts/prepare-toolchain.py`. It builds both the host interpreter and target interpreter from Python 3.11.18. OpenSSL and libffi use the pinned toolchain's recipes.

Outputs are written to `artifacts/`. The matching standard library is copied to `Sources/PythonSupport/lib`, and `Package.swift` is generated with the release URLs and SHA-256 checksums. The manually triggered GitHub Actions workflow produces the same files for download; it does not publish a release automatically.

## Validate and release

Boot an iOS simulator, then run:

```sh
sh Scripts/smoke-test.sh SIMULATOR_UDID
```

This compiles and runs an iOS simulator executable against the built static libraries, checking the Python version, standard-library imports, compression, SQLite, ctypes, ZIP files, and threads. App-level tests must also cover the consuming application's PythonKit and FFmpeg integration. A simulator pass does not replace a physical-device test.

Commit the generated manifest and standard library together. Publish the four `artifacts/*.xcframework.zip` files under the same release tag passed to `Scripts/ci.sh`. Existing release assets should not be replaced because clients verify their checksums.

## License

The wrapper retains the upstream MIT license. CPython, OpenSSL, and libffi retain their respective licenses.
