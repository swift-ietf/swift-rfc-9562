# swift-rfc-9562

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Generation and parsing of UUIDs per RFC 9562, including versions 1 through 8.

## Standard Reference

- **RFC**: 9562
- **Title**: Universally Unique IDentifiers (UUIDs)

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-9562.git", branch: "main")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 9562", package: "swift-rfc-9562")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
