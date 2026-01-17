// RFC_9562.Timestamp.swift
// Timestamp extraction for v7 UUIDs per RFC 9562

public import RFC_4122

// MARK: - Timestamp Extraction

extension RFC_9562.UUID {
    /// The Unix timestamp in milliseconds for a v7 UUID.
    ///
    /// For v7 UUIDs, the first 48 bits (bytes 0-5) contain the Unix timestamp
    /// in milliseconds since the Unix epoch (January 1, 1970 00:00:00 UTC).
    ///
    /// Returns `nil` if this is not a v7 UUID.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let uuid = try RFC_9562.UUID("018f0b69-7c00-7000-8000-000000000000")
    /// if let millis = uuid.unixMilliseconds {
    ///     print("Created at: \(millis) ms since epoch")
    /// }
    /// ```
    public var unixMilliseconds: Int64? {
        guard versionNumber == 7 else { return nil }

        // Extract 48-bit timestamp from bytes 0-5 (big-endian)
        let b0 = Int64(bytes.0)
        let b1 = Int64(bytes.1)
        let b2 = Int64(bytes.2)
        let b3 = Int64(bytes.3)
        let b4 = Int64(bytes.4)
        let b5 = Int64(bytes.5)

        return (b0 << 40) | (b1 << 32) | (b2 << 24) | (b3 << 16) | (b4 << 8) | b5
    }

    /// The Unix timestamp in seconds for a v7 UUID.
    ///
    /// Convenience property that returns the timestamp in seconds rather than milliseconds.
    /// Returns `nil` if this is not a v7 UUID.
    public var unixSeconds: Int64? {
        guard let millis = unixMilliseconds else { return nil }
        return millis / 1000
    }
}
