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
        .package(url: "https://github.com/vapor/multipart-kit.git", from: "4.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.5"),
    ],
    targets: [
        .target(
            name: "MailgunKit",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
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
