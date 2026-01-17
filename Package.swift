// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-rfc-9562",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "RFC 9562",
            targets: ["RFC 9562"]
        )
    ],
    dependencies: [
        .package(path: "../swift-rfc-4122"),
        .package(path: "../../swift-foundations/swift-testing-extras"),
    ],
    targets: [
        .target(
            name: "RFC 9562",
            dependencies: [
                .product(name: "RFC 4122", package: "swift-rfc-4122"),
            ]
        ),
        .testTarget(
            name: "RFC 9562".tests,
            dependencies: [
                "RFC 9562",
                .product(name: "Testing Extras", package: "swift-testing-extras"),
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
