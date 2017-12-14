// swift-tools-version:4.0

import PackageDescription
let package = Package(
    name: "amy_website",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/watson-developer-cloud/swift-sdk.git", .upToNextMajor(from: "0.19.0")),
        .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/brokenhandsio/leaf-error-middleware.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentProvider","ConversationV1","LeafProvider","LeafErrorMiddleware"],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)

