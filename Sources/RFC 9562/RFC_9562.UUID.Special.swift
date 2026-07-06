// RFC_9562.UUID.Special.swift
// Special UUID values per RFC 9562 Section 5.9 and 5.10

public import RFC_4122

// MARK: - Special UUIDs

extension RFC_9562.UUID {
    /// The nil UUID: all zeros.
    ///
    /// RFC 9562 Section 5.9 defines the nil UUID as `00000000-0000-0000-0000-000000000000`.
    /// It has no inherent meaning and can be used as a placeholder or sentinel value.
    ///
    /// - Note: The nil UUID does not have a valid version or variant field.
    public static let `nil` = Self(
        bytes: (
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00
        )
    )

    /// The max UUID: all ones.
    ///
    /// RFC 9562 Section 5.10 defines the max UUID as `ffffffff-ffff-ffff-ffff-ffffffffffff`.
    /// It can be used for sorting or as a sentinel representing the maximum possible value.
    ///
    /// - Note: The max UUID does not have a valid version or variant field.
    public static let max = Self(
        bytes: (
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF
        )
    )

    /// Whether this UUID is the nil UUID (all zeros).
    public var isNil: Bool {
        self == .nil
    }

    /// Whether this UUID is the max UUID (all ones).
    public var isMax: Bool {
        self == .max
    }
}
