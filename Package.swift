// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swift-Convert-JWK-PEM",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Swift-Convert-JWK-PEM",
            targets: ["Swift-Convert-JWK-PEM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/TakeScoop/SwiftyRSA", .upToNextMajor(from: "1.8.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Swift-Convert-JWK-PEM",
            dependencies: [
                .product(name: "SwiftyRSA", package: "SwiftyRSA")
            ]),
        .testTarget(
            name: "Swift-Convert-JWK-PEMTests",
            dependencies: ["Swift-Convert-JWK-PEM"]),
    ]
)
