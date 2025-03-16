// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KocomSwift",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "KocomSwift", targets: ["KocomSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server-community/mqtt-nio", exact: Version(2, 12, 0)),

    ],
    targets: [
        .executableTarget(
            name: "KocomSwift",
            dependencies: [
                .product(name: "MQTTNIO", package: "mqtt-nio"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "KocomSwiftTests",
            dependencies: ["KocomSwift"]
        ),
    ]
)
