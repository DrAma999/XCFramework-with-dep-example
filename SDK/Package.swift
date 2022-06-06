// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDK",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SDK",
            targets: ["SDK"]),
        .library(
            name: "SDKPrivate",
            targets: ["SDKPrivate"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "../PublicSDK"),
        .package(path: "../ImpOnlyA"),
        .package(path: "../ImpOnlyB")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SDK",
            dependencies: ["PublicSDK", "ImpOnlyA", "ImpOnlyB"]
        ),
        .target(
            name: "SDKPrivate",
            dependencies: ["PublicSDK", "ImpOnlyA", "ImpOnlyB"],
            swiftSettings: [.define("PVT")]
        ),
        .testTarget(
            name: "SDKTests",
            dependencies: ["SDKPrivate"])
    ]
)
