// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "mailgun-kit",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "MailgunKit",
            targets: ["MailgunKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.27.0"),
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.5.1"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.6.3"),
    ],
    targets: [
        .target(
            name: "MailgunKit",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "MultipartKit", package: "multipart-kit"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
        .testTarget(
            name: "MailgunKitTests",
            dependencies: ["MailgunKit"]
        ),
    ]
)
