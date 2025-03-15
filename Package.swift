// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KocomSwift",
    products: [
        .executable(name: "KocomSwift", targets: ["KocomSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server-community/mqtt-nio", exact: Version(7, 6, 5)),
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", exact: Version(7, 6, 5))
    ],
    targets: [
        .executableTarget(
            name: "KocomSwift",
            dependencies: [
                .product(name: "MQTTNIO", package: "mqtt-nio"),
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
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
