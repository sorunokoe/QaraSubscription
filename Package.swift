// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QaraSubscription",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "QaraSubscription",
            type: .dynamic,
            targets: ["QaraSubscription"]),
    ],
    dependencies: [
        .package(name: "RevenueCat", url: "https://github.com/RevenueCat/purchases-ios-spm.git", .upToNextMajor(from: "4.41.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "QaraSubscription",
            dependencies: [
                .product(name: "RevenueCat", package: "RevenueCat"),
                .product(name: "RevenueCatUI", package: "RevenueCat")
            ]
        ),
        .testTarget(
            name: "QaraSubscriptionTests",
            dependencies: ["QaraSubscription"]),
    ]
)
