// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STLKit",
    platforms: [.visionOS(.v1), .iOS(.v17), .macOS(.v14), .macCatalyst(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "STLKit",
            targets: ["STLKit"]),
    ],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", .upToNextMajor(from: "1.3.0")),],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "STLKit"
        ),
        .testTarget(
            name: "STLKitTests",
            dependencies: ["STLKit"],
        resources: [
            .copy("300_polygon_sphere_100mm.STL")]),
    ]
)
