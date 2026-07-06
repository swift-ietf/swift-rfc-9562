// RFC_9562.UUID.Generation.swift
// UUID generation for RFC 9562 versions (v6, v7, v8)

public import RFC_4122

// MARK: - Random Provider Protocol

extension RFC_9562 {
    /// Protocol for providing random bytes to UUID generators.
    ///
    /// Implement this protocol to provide cryptographically secure random bytes
    /// for UUID generation. The implementation should use a CSPRNG.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct SystemRandom: RFC_9562.RandomProvider {
    ///     func fill(_ buffer: UnsafeMutableRawBufferPointer) throws {
    ///         // Use platform CSPRNG
    ///     }
    /// }
    /// ```
    public protocol RandomProvider: Sendable {
        /// Error type thrown by the random provider.
        associatedtype RandomError: Error

        /// Fills the buffer with cryptographically secure random bytes.
        ///
        /// - Parameter buffer: The buffer to fill with random bytes.
        /// - Throws: An error if random bytes cannot be generated.
        func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(RandomError)
    }
}

// MARK: - Version 7 Generation

extension RFC_9562.UUID {
    /// Generates a version 7 UUID with the given Unix timestamp.
    ///
    /// Version 7 UUIDs (RFC 9562 Section 5.7) combine a 48-bit Unix timestamp
    /// in milliseconds with random data. They are time-ordered and suitable
    /// for use as database keys.
    ///
    /// ## Bit Layout
    ///
    /// ```
    /// 0                   1                   2                   3
    ///  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |                         unix_ts_ms (32 bits)                 |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |          unix_ts_ms (16 bits) |  ver  |   rand_a (12 bits)   |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |var|                    rand_b (62 bits)                      |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |                         rand_b (continued)                   |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// ```
    ///
    /// - Parameters:
    ///   - unixMilliseconds: Unix timestamp in milliseconds since epoch.
    ///     Must be non-negative and fit in 48 bits (0 to 281,474,976,710,655).
    ///   - random: A random provider for generating random bytes.
    /// - Returns: A version 7 UUID.
    /// - Throws: `RandomError` if random bytes cannot be generated.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let now: Int64 = 1645557742000  // 2022-02-22T19:22:22.000Z
    /// let uuid = try RFC_9562.UUID.v7(unixMilliseconds: now, using: SystemRandom())
    /// print(uuid)  // 017f22e2-79b0-7xxx-xxxx-xxxxxxxxxxxx
    /// ```
    public static func v7<R: RFC_9562.RandomProvider>(
        unixMilliseconds: Int64,
        using random: R
    ) throws(R.RandomError) -> Self {
        // Validate timestamp fits in 48 bits
        precondition(unixMilliseconds >= 0, "Unix timestamp must be non-negative")
        precondition(unixMilliseconds <= 0xFFFF_FFFF_FFFF, "Unix timestamp must fit in 48 bits")

        var bytes:
            (
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8
            ) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

        // Fill bytes 6-15 with random data (bytes 0-5 will be overwritten with timestamp)
        let outcome: Result<Void, R.RandomError> = Swift.withUnsafeMutableBytes(of: &bytes) { buffer in
            // Fill only bytes 6-15 with random data
            let randomBuffer = UnsafeMutableRawBufferPointer(
                rebasing: buffer[6...]
            )
            do throws(R.RandomError) {
                try random.fill(randomBuffer)
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        try outcome.get()

        // Set timestamp in bytes 0-5 (big-endian, 48 bits)
        bytes.0 = UInt8((unixMilliseconds >> 40) & 0xFF)
        bytes.1 = UInt8((unixMilliseconds >> 32) & 0xFF)
        bytes.2 = UInt8((unixMilliseconds >> 24) & 0xFF)
        bytes.3 = UInt8((unixMilliseconds >> 16) & 0xFF)
        bytes.4 = UInt8((unixMilliseconds >> 8) & 0xFF)
        bytes.5 = UInt8(unixMilliseconds & 0xFF)

        // Set version 7 in byte 6, high nibble (preserve random low nibble)
        bytes.6 = (bytes.6 & 0x0F) | 0x70

        // Set RFC 4122 variant in byte 8, high 2 bits (preserve random low 6 bits)
        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return Self(bytes: bytes)
    }

    /// Generates a version 7 UUID with the given Unix timestamp using a closure for random bytes.
    ///
    /// This overload accepts a closure instead of a `RandomProvider` conforming type,
    /// which can be convenient for one-off usage or when wrapping platform APIs.
    ///
    /// - Parameters:
    ///   - unixMilliseconds: Unix timestamp in milliseconds since epoch.
    ///   - fillRandom: A closure that fills the provided buffer with random bytes.
    /// - Returns: A version 7 UUID.
    /// - Throws: Any error thrown by the `fillRandom` closure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let uuid = try RFC_9562.UUID.v7(unixMilliseconds: 1645557742000) { buffer in
    ///     // Fill buffer with random bytes from your CSPRNG
    ///     try myCSPRNG.fill(buffer)
    /// }
    /// ```
    public static func v7<E: Swift.Error>(
        unixMilliseconds: Int64,
        fillRandom: (UnsafeMutableRawBufferPointer) throws(E) -> Void
    ) throws(E) -> Self {
        precondition(unixMilliseconds >= 0, "Unix timestamp must be non-negative")
        precondition(unixMilliseconds <= 0xFFFF_FFFF_FFFF, "Unix timestamp must fit in 48 bits")

        var bytes:
            (
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8
            ) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

        // Fill bytes 6-15 with random data
        let outcome: Result<Void, E> = Swift.withUnsafeMutableBytes(of: &bytes) { buffer in
            let randomBuffer = UnsafeMutableRawBufferPointer(rebasing: buffer[6...])
            do throws(E) {
                try fillRandom(randomBuffer)
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        try outcome.get()

        // Set timestamp in bytes 0-5 (big-endian)
        bytes.0 = UInt8((unixMilliseconds >> 40) & 0xFF)
        bytes.1 = UInt8((unixMilliseconds >> 32) & 0xFF)
        bytes.2 = UInt8((unixMilliseconds >> 24) & 0xFF)
        bytes.3 = UInt8((unixMilliseconds >> 16) & 0xFF)
        bytes.4 = UInt8((unixMilliseconds >> 8) & 0xFF)
        bytes.5 = UInt8(unixMilliseconds & 0xFF)

        // Set version 7
        bytes.6 = (bytes.6 & 0x0F) | 0x70

        // Set RFC 4122 variant
        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return Self(bytes: bytes)
    }
}

// MARK: - Version 8 Generation

extension RFC_9562.UUID {
    /// Creates a version 8 UUID with custom application-specific data.
    ///
    /// Version 8 UUIDs (RFC 9562 Section 5.8) allow applications to define
    /// their own UUID format using the 122 bits not reserved for version
    /// and variant fields.
    ///
    /// The caller provides all 16 bytes; this method only sets the version
    /// and variant bits appropriately.
    ///
    /// - Parameter customBytes: 16 bytes of application-specific data.
    ///   Bytes 6 (high nibble) and 8 (high 2 bits) will be overwritten
    ///   with version and variant bits.
    /// - Returns: A version 8 UUID.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var data: [UInt8] = [/* your 16 bytes */]
    /// let uuid = RFC_9562.UUID.v8(customBytes: data)
    /// ```
    public static func v8(customBytes: [UInt8]) -> Self {
        precondition(customBytes.count == 16, "Custom bytes must be exactly 16 bytes")

        var bytes = (
            customBytes[0], customBytes[1], customBytes[2], customBytes[3],
            customBytes[4], customBytes[5], customBytes[6], customBytes[7],
            customBytes[8], customBytes[9], customBytes[10], customBytes[11],
            customBytes[12], customBytes[13], customBytes[14], customBytes[15]
        )

        // Set version 8
        bytes.6 = (bytes.6 & 0x0F) | 0x80

        // Set RFC 4122 variant
        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return Self(bytes: bytes)
    }

    /// Creates a version 8 UUID with custom application-specific data from a tuple.
    ///
    /// - Parameter customBytes: 16 bytes as a tuple.
    /// - Returns: A version 8 UUID.
    public static func v8(
        customBytes: (
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8
        )
    ) -> Self {
        var bytes = customBytes

        // Set version 8
        bytes.6 = (bytes.6 & 0x0F) | 0x80

        // Set RFC 4122 variant
        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return Self(bytes: bytes)
    }
}
