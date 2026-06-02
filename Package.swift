// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-rfc-9562",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "RFC 9562",
            targets: ["RFC 9562"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-4122.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RFC 9562",
            dependencies: [
                .product(name: "RFC 4122", package: "swift-rfc-4122")
            ]
        ),
        .testTarget(
            name: "RFC 9562 Tests",
            dependencies: [
                "RFC 9562",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
