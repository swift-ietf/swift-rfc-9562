public import RFC_4122

extension RFC_9562 {

    public protocol RandomProvider: Sendable {

        associatedtype RandomError: Swift.Error

        func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(RandomError)
    }
}

extension RFC_9562.UUID {

    public static func v7<R: RFC_9562.RandomProvider>(
        unixMilliseconds: Int64,
        using random: R
    ) throws(R.RandomError) -> Self {

        precondition(unixMilliseconds >= 0, "Unix timestamp must be non-negative")
        precondition(unixMilliseconds <= 0xFFFF_FFFF_FFFF, "Unix timestamp must fit in 48 bits")

        var bytes:
            (
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8
            ) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

        let outcome: Result<Void, R.RandomError> = Swift.withUnsafeMutableBytes(of: &bytes) {
            buffer in

            let randomBuffer = unsafe UnsafeMutableRawBufferPointer(
                rebasing: buffer[6...]
            )
            do throws(R.RandomError) {
                try unsafe random.fill(randomBuffer)
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        try outcome.get()

        bytes.0 = UInt8((unixMilliseconds >> 40) & 0xFF)
        bytes.1 = UInt8((unixMilliseconds >> 32) & 0xFF)
        bytes.2 = UInt8((unixMilliseconds >> 24) & 0xFF)
        bytes.3 = UInt8((unixMilliseconds >> 16) & 0xFF)
        bytes.4 = UInt8((unixMilliseconds >> 8) & 0xFF)
        bytes.5 = UInt8(unixMilliseconds & 0xFF)

        bytes.6 = (bytes.6 & 0x0F) | 0x70

        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return Self(bytes: bytes)
    }

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

        let outcome: Result<Void, E> = Swift.withUnsafeMutableBytes(of: &bytes) { buffer in
            let randomBuffer = unsafe UnsafeMutableRawBufferPointer(rebasing: buffer[6...])
            do throws(E) {
                try unsafe fillRandom(randomBuffer)
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        try outcome.get()

        bytes.0 = UInt8((unixMilliseconds >> 40) & 0xFF)
        bytes.1 = UInt8((unixMilliseconds >> 32) & 0xFF)
        bytes.2 = UInt8((unixMilliseconds >> 24) & 0xFF)
        bytes.3 = UInt8((unixMilliseconds >> 16) & 0xFF)
        bytes.4 = UInt8((unixMilliseconds >> 8) & 0xFF)
        bytes.5 = UInt8(unixMilliseconds & 0xFF)

        bytes.6 = (bytes.6 & 0x0F) | 0x70

        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return Self(bytes: bytes)
    }
}

extension RFC_9562.UUID {

    public static func v8(customBytes: [UInt8]) -> Self {
        precondition(customBytes.count == 16, "Custom bytes must be exactly 16 bytes")

        var bytes = (
            customBytes[0], customBytes[1], customBytes[2], customBytes[3],
            customBytes[4], customBytes[5], customBytes[6], customBytes[7],
            customBytes[8], customBytes[9], customBytes[10], customBytes[11],
            customBytes[12], customBytes[13], customBytes[14], customBytes[15]
        )

        bytes.6 = (bytes.6 & 0x0F) | 0x80

        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return Self(bytes: bytes)
    }

    public static func v8(
        customBytes: (
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8
        )
    ) -> Self {
        var bytes = customBytes

        bytes.6 = (bytes.6 & 0x0F) | 0x80

        bytes.8 = (bytes.8 & 0x3F) | 0x80

        return Self(bytes: bytes)
    }
}
