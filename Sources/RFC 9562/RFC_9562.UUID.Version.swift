// RFC_9562.UUID.Version.swift
// Extended UUID version field per RFC 9562

public import RFC_4122

extension RFC_9562 {
    /// The complete UUID version as defined in RFC 9562.
    ///
    /// This enum includes all versions from both RFC 4122 and RFC 9562.
    /// For new applications, version 7 (Unix epoch time-based) is recommended
    /// as it provides good time-ordering properties with minimal coordination.
    public enum Version: UInt8, Sendable, Hashable {
        /// Time-based version using MAC address and timestamp (RFC 4122).
        case v1 = 1

        /// DCE Security version with POSIX UIDs (RFC 4122).
        case v2 = 2

        /// Name-based version using MD5 hashing (RFC 4122).
        case v3 = 3

        /// Randomly or pseudo-randomly generated version (RFC 4122).
        case v4 = 4

        /// Name-based version using SHA-1 hashing (RFC 4122).
        case v5 = 5

        /// Reordered time-based version (RFC 9562).
        ///
        /// Similar to v1 but with bytes reordered for improved database indexing.
        /// The timestamp is in the most significant bits for natural sorting.
        case v6 = 6

        /// Unix epoch time-based version (RFC 9562).
        ///
        /// Recommended for new applications. Combines:
        /// - 48-bit Unix timestamp in milliseconds (big-endian)
        /// - 4-bit version
        /// - 12-bit random data
        /// - 2-bit variant
        /// - 62-bit random data
        case v7 = 7

        /// Custom application-specific version (RFC 9562).
        ///
        /// All bits (except version and variant) are application-defined.
        case v8 = 8
    }
}

extension RFC_9562.UUID {
    /// The version of this UUID as a complete RFC 9562 version.
    ///
    /// Returns `nil` if the version bits contain a value not defined in RFC 9562
    /// (0 or 9-15).
    public var version9562: RFC_9562.Version? {
        RFC_9562.Version(rawValue: versionNumber)
    }
}
