// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Python-iOS",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Python-iOS",
            targets: [ // order matters!
                "LinkPython",
                "libpython3", "libssl", "libcrypto", "libffi",
                "PythonSupport",
            ]),
    ],
    targets: [
        .binaryTarget(name: "libpython3", url: "https://github.com/vince-hz/Python-iOS/releases/download/3.11.18-1/libpython3.xcframework.zip", checksum: "9d03d2fe865a890f60e095ad9ea4b432191adcff042a66372477e3a359a64369"),
        .binaryTarget(name: "libssl", url: "https://github.com/vince-hz/Python-iOS/releases/download/3.11.18-1/libssl.xcframework.zip", checksum: "98046521a6de1f1a7a463d1021415672b2cad5e19d8108d8021abc12276bb93d"),
        .binaryTarget(name: "libcrypto", url: "https://github.com/vince-hz/Python-iOS/releases/download/3.11.18-1/libcrypto.xcframework.zip", checksum: "5b8d6ba865a97ffd4b85b223014d23931ae89328b43d826eef5a7b085a7d86af"),
        .binaryTarget(name: "libffi", url: "https://github.com/vince-hz/Python-iOS/releases/download/3.11.18-1/libffi.xcframework.zip", checksum: "cdbc800e726e24a7cdc94d5dccae0150ba685953cf03f93b1a2060842dd5c440"),
        .target(name: "LinkPython",
                dependencies: [
                    "libpython3",
                    "libssl",
                    "libcrypto",
                    "libffi",
                ],
                linkerSettings: [
                    .linkedLibrary("z"),
                    .linkedLibrary("bz2"),
                    .linkedLibrary("sqlite3"),
                ]
        ),
        .target(name: "PythonSupport",
                dependencies: ["LinkPython"],
                resources: [.copy("lib")]),
        .testTarget(
            name: "PythonTests",
            dependencies: ["PythonSupport"]),
    ]
)
