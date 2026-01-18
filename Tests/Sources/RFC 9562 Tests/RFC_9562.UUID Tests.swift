// RFC_9562.UUID Tests.swift

import Testing
import Testing
import RFC_4122
@testable import RFC_9562

extension RFC_9562.UUID {
    #Tests
}

// MARK: - Unit Tests

extension RFC_9562.UUID.Test.Unit {

    // MARK: Special UUIDs

    @Test("Nil UUID is all zeros")
    func nilUUID() {
        let uuid = RFC_9562.UUID.nil
        #expect(uuid.description == "00000000-0000-0000-0000-000000000000")
        #expect(uuid.isNil)
        #expect(!uuid.isMax)
    }

    @Test("Max UUID is all ones")
    func maxUUID() {
        let uuid = RFC_9562.UUID.max
        #expect(uuid.description == "ffffffff-ffff-ffff-ffff-ffffffffffff")
        #expect(uuid.isMax)
        #expect(!uuid.isNil)
    }

    @Test("Regular UUID is neither nil nor max")
    func regularUUID() throws {
        let uuid = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        #expect(!uuid.isNil)
        #expect(!uuid.isMax)
    }

    // MARK: Version Detection (RFC 9562 extended versions)

    @Test("Detects v1")
    func version1() throws {
        let uuid = try RFC_9562.UUID("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
        #expect(uuid.version9562 == .v1)
    }

    @Test("Detects v4")
    func version4() throws {
        let uuid = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        #expect(uuid.version9562 == .v4)
    }

    @Test("Detects v6")
    func version6() throws {
        let uuid = try RFC_9562.UUID("1ec9414c-232a-6b00-b3c8-9f6bdeced846")
        #expect(uuid.version9562 == .v6)
    }

    @Test("Detects v7")
    func version7() throws {
        let uuid = try RFC_9562.UUID("018f0b69-7c00-7000-8000-000000000000")
        #expect(uuid.version9562 == .v7)
    }

    @Test("Detects v8")
    func version8() throws {
        let uuid = try RFC_9562.UUID("00000000-0000-8000-8000-000000000000")
        #expect(uuid.version9562 == .v8)
    }

    // MARK: Timestamp Extraction

    @Test("Extracts milliseconds from v7 UUID")
    func extractsMilliseconds() throws {
        let uuid = try RFC_9562.UUID("018e0b69-7c00-7000-8000-000000000000")
        #expect(uuid.unixMilliseconds == 0x018E0B697C00)
    }

    @Test("Extracts seconds from v7 UUID")
    func extractsSeconds() throws {
        let uuid = try RFC_9562.UUID("018e0b69-7c00-7000-8000-000000000000")
        guard let seconds = uuid.unixSeconds else {
            Issue.record("Expected seconds to be non-nil")
            return
        }
        #expect(seconds == 0x018E0B697C00 / 1000)
    }

    // MARK: Type Alias

    @Test("RFC_9562.UUID is RFC_4122.UUID")
    func typeAliasCheck() throws {
        let rfc9562uuid: RFC_9562.UUID = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        let rfc4122uuid: RFC_4122.UUID = rfc9562uuid
        #expect(rfc4122uuid == rfc9562uuid)
    }
}

// MARK: - RFC 9562 Test Vectors

extension RFC_9562.UUID.Test.Unit {

    // MARK: RFC 9562 Section 5.7 - UUIDv7 Test Vectors

    @Test("RFC 9562: v7 timestamp extraction (known vector)")
    func v7TimestampVector() throws {
        // Example from RFC 9562 - timestamp 0x017F22E279B0 = 1645557742000 ms
        // UUID: 017f22e2-79b0-7cc3-98c4-dc0c0c07398f
        let uuid = try RFC_9562.UUID("017f22e2-79b0-7cc3-98c4-dc0c0c07398f")
        #expect(uuid.version9562 == .v7)
        #expect(uuid.variant == .rfc4122)
        #expect(uuid.unixMilliseconds == 0x017F22E279B0)
        // Verify: 2022-02-22T19:22:22.000Z
        #expect(uuid.unixMilliseconds == 1645557742000)
    }

    @Test("RFC 9562: v7 bit layout verification")
    func v7BitLayout() throws {
        // Construct a v7 UUID and verify the bit layout
        // Timestamp: 0x018EC3C5D400 (known value)
        let uuid = try RFC_9562.UUID("018ec3c5-d400-7000-8000-000000000000")
        #expect(uuid.version9562 == .v7)
        #expect(uuid.versionNumber == 7)
        #expect(uuid.variant == .rfc4122)

        // Verify timestamp bytes (0-5)
        #expect(uuid[0] == 0x01)
        #expect(uuid[1] == 0x8e)
        #expect(uuid[2] == 0xc3)
        #expect(uuid[3] == 0xc5)
        #expect(uuid[4] == 0xd4)
        #expect(uuid[5] == 0x00)

        // Verify version nibble in byte 6
        #expect((uuid[6] & 0xF0) == 0x70)  // Version 7

        // Verify variant bits in byte 8
        #expect((uuid[8] & 0xC0) == 0x80)  // RFC 4122 variant
    }

    // MARK: RFC 9562 Section 5.6 - UUIDv6 Test Vectors

    @Test("RFC 9562: v6 structure verification")
    func v6Structure() throws {
        // UUIDv6 is a reordered v1 for better sortability
        let uuid = try RFC_9562.UUID("1ec9414c-232a-6b00-b3c8-9f6bdeced846")
        #expect(uuid.version9562 == .v6)
        #expect(uuid.versionNumber == 6)
        #expect(uuid.variant == .rfc4122)

        // Version nibble should be 6
        #expect((uuid[6] & 0xF0) == 0x60)
    }

    // MARK: RFC 9562 Section 5.8 - UUIDv8 Test Vectors

    @Test("RFC 9562: v8 custom UUID")
    func v8Custom() throws {
        // v8 allows custom data in all bits except version and variant
        let uuid = try RFC_9562.UUID("320c3d4d-cc00-875b-8ec9-32d5f69181c0")
        #expect(uuid.version9562 == .v8)
        #expect(uuid.versionNumber == 8)
        #expect(uuid.variant == .rfc4122)

        // Version nibble should be 8
        #expect((uuid[6] & 0xF0) == 0x80)
    }

    // MARK: RFC 9562 Section 5.9/5.10 - Special UUIDs

    @Test("RFC 9562: Nil UUID byte verification")
    func nilUUIDBytes() {
        let uuid = RFC_9562.UUID.nil
        for i in 0..<16 {
            #expect(uuid[i] == 0x00)
        }
        // Nil UUID has no valid version (all zeros)
        #expect(uuid.version9562 == nil)
    }

    @Test("RFC 9562: Max UUID byte verification")
    func maxUUIDBytes() {
        let uuid = RFC_9562.UUID.max
        for i in 0..<16 {
            #expect(uuid[i] == 0xFF)
        }
        // Max UUID has no valid version (0xF = 15, not defined)
        #expect(uuid.version9562 == nil)
    }

    // MARK: Timestamp Edge Cases

    @Test("v7 timestamp: Unix epoch (zero)")
    func v7TimestampZero() throws {
        // Timestamp = 0 (1970-01-01T00:00:00.000Z)
        let uuid = try RFC_9562.UUID("00000000-0000-7000-8000-000000000000")
        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == 0)
    }

    @Test("v7 timestamp: Maximum 48-bit value")
    func v7TimestampMax() throws {
        // Timestamp = 0xFFFFFFFFFFFF (max 48-bit)
        let uuid = try RFC_9562.UUID("ffffffff-ffff-7000-8000-000000000000")
        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == 0xFFFFFFFFFFFF)
        // This is year 10889 AD
    }
}

// MARK: - Edge Cases

extension RFC_9562.UUID.Test.EdgeCase {
    @Test("Returns nil timestamp for non-v7 UUID")
    func nilForNonV7() throws {
        let v4uuid = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        #expect(v4uuid.unixMilliseconds == nil)
        #expect(v4uuid.unixSeconds == nil)
    }

    @Test("Returns nil version for invalid version number")
    func nilForInvalidVersion() throws {
        // Version 0 is not valid
        let uuid = try RFC_9562.UUID("00000000-0000-0000-8000-000000000000")
        #expect(uuid.version9562 == nil)
        #expect(uuid.versionNumber == 0)
    }

    @Test("Returns nil version for version 9+")
    func nilForVersion9Plus() throws {
        // Version 9 is not defined
        let uuid = try RFC_9562.UUID("00000000-0000-9000-8000-000000000000")
        #expect(uuid.version9562 == nil)
        #expect(uuid.versionNumber == 9)
    }
}

// MARK: - Generation Tests

/// Mock random provider for deterministic testing
private struct MockRandom: RFC_9562.RandomProvider {
    let pattern: UInt8

    func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(Never) {
        for i in buffer.indices {
            buffer[i] = pattern
        }
    }
}

/// Mock random provider that fills with sequential bytes
private struct SequentialRandom: RFC_9562.RandomProvider {
    let start: UInt8

    func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(Never) {
        for (i, index) in buffer.indices.enumerated() {
            buffer[index] = start &+ UInt8(i)
        }
    }
}

// MARK: - Performance

extension RFC_9562.UUID.Test.Performance {

    // MARK: v7 Generation

    @Test("v7 generation", .timed(iterations: 1000, warmup: 100))
    func v7Generation() throws {
        _ = try RFC_9562.UUID.v7(
            unixMilliseconds: 1645557742000,
            using: PerfRandom()
        )
    }

    @Test("v7 generation batch (1000 UUIDs)")
    func v7GenerationBatch() {
        let random = PerfRandom()
        Benchmark.measure(iterations: 10, warmup: 2, name: "v7 x1000") {
            for i in 0..<1000 {
                _ = try? RFC_9562.UUID.v7(
                    unixMilliseconds: Int64(1645557742000 + i),
                    using: random
                )
            }
        }
    }

    @Test("v7 closure-based generation", .timed(iterations: 1000, warmup: 100))
    func v7ClosureGeneration() throws {
        _ = try RFC_9562.UUID.v7(unixMilliseconds: 1645557742000) { buffer in
            for i in buffer.indices {
                buffer[i] = UInt8(truncatingIfNeeded: i)
            }
        }
    }

    // MARK: v8 Generation

    @Test("v8 generation (array)", .timed(iterations: 1000, warmup: 100))
    func v8GenerationArray() {
        let bytes: [UInt8] = [
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x06, 0x07, 0x08,
            0x09, 0x0A, 0x0B, 0x0C,
            0x0D, 0x0E, 0x0F, 0x10
        ]
        _ = RFC_9562.UUID.v8(customBytes: bytes)
    }

    @Test("v8 generation (tuple)", .timed(iterations: 1000, warmup: 100))
    func v8GenerationTuple() {
        _ = RFC_9562.UUID.v8(customBytes: (
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x06, 0x07, 0x08,
            0x09, 0x0A, 0x0B, 0x0C,
            0x0D, 0x0E, 0x0F, 0x10
        ))
    }

    // MARK: Timestamp Extraction

    @Test("Timestamp extraction (milliseconds)", .timed(iterations: 1000, warmup: 100))
    func timestampMilliseconds() throws {
        let uuid = try RFC_9562.UUID("018e0b69-7c00-7000-8000-000000000000")
        _ = uuid.unixMilliseconds
    }

    @Test("Timestamp extraction (seconds)", .timed(iterations: 1000, warmup: 100))
    func timestampSeconds() throws {
        let uuid = try RFC_9562.UUID("018e0b69-7c00-7000-8000-000000000000")
        _ = uuid.unixSeconds
    }

    // MARK: Version Detection (RFC 9562 extended)

    @Test("Version detection (v6-v8)", .timed(iterations: 1000, warmup: 100))
    func version9562Detection() throws {
        let uuid = try RFC_9562.UUID("018f0b69-7c00-7000-8000-000000000000")
        _ = uuid.version9562
    }

    // MARK: Special UUIDs

    @Test("Nil UUID check", .timed(iterations: 1000, warmup: 100))
    func nilCheck() {
        let uuid = RFC_9562.UUID.nil
        _ = uuid.isNil
    }

    @Test("Max UUID check", .timed(iterations: 1000, warmup: 100))
    func maxCheck() {
        let uuid = RFC_9562.UUID.max
        _ = uuid.isMax
    }
}

/// Lightweight random provider for performance testing
private struct PerfRandom: RFC_9562.RandomProvider {
    func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(Never) {
        for i in buffer.indices {
            buffer[i] = UInt8(truncatingIfNeeded: i)
        }
    }
}

extension RFC_9562.UUID.Test.Unit {

    // MARK: v7 Generation

    @Test("v7 generates correct version and variant")
    func v7VersionAndVariant() throws {
        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: 1645557742000,
            using: MockRandom(pattern: 0xAA)
        )

        #expect(uuid.version9562 == .v7)
        #expect(uuid.versionNumber == 7)
        #expect(uuid.variant == .rfc4122)
    }

    @Test("v7 encodes timestamp correctly")
    func v7Timestamp() throws {
        let timestamp: Int64 = 0x017F22E279B0  // 1645557742000

        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: timestamp,
            using: MockRandom(pattern: 0x00)
        )

        // Verify timestamp is encoded in bytes 0-5
        #expect(uuid.unixMilliseconds == timestamp)

        // Verify individual bytes
        #expect(uuid[0] == 0x01)
        #expect(uuid[1] == 0x7F)
        #expect(uuid[2] == 0x22)
        #expect(uuid[3] == 0xE2)
        #expect(uuid[4] == 0x79)
        #expect(uuid[5] == 0xB0)
    }

    @Test("v7 preserves random bits in rand_a")
    func v7RandA() throws {
        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: 0,
            using: MockRandom(pattern: 0xFF)
        )

        // Byte 6 low nibble should be preserved (0xF from random)
        // High nibble is version (0x7)
        #expect(uuid[6] == 0x7F)
    }

    @Test("v7 preserves random bits in rand_b")
    func v7RandB() throws {
        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: 0,
            using: MockRandom(pattern: 0xFF)
        )

        // Byte 8 low 6 bits should be preserved (0x3F from random)
        // High 2 bits are variant (0x80)
        #expect(uuid[8] == 0xBF)  // 10111111

        // Bytes 9-15 should be fully random
        for i in 9..<16 {
            #expect(uuid[i] == 0xFF)
        }
    }

    @Test("v7 with zero timestamp")
    func v7ZeroTimestamp() throws {
        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: 0,
            using: MockRandom(pattern: 0x00)
        )

        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == 0)

        // Bytes 0-5 should all be zero
        for i in 0..<6 {
            #expect(uuid[i] == 0x00)
        }
    }

    @Test("v7 with maximum 48-bit timestamp")
    func v7MaxTimestamp() throws {
        let maxTimestamp: Int64 = 0xFFFF_FFFF_FFFF

        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: maxTimestamp,
            using: MockRandom(pattern: 0x00)
        )

        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == maxTimestamp)

        // Bytes 0-5 should all be 0xFF
        for i in 0..<6 {
            #expect(uuid[i] == 0xFF)
        }
    }

    @Test("v7 closure-based generation")
    func v7Closure() throws {
        let uuid = try RFC_9562.UUID.v7(unixMilliseconds: 1000) { buffer in
            for i in buffer.indices {
                buffer[i] = 0x55
            }
        }

        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == 1000)
    }

    // MARK: v8 Generation

    @Test("v8 generates correct version and variant")
    func v8VersionAndVariant() throws {
        let customBytes: [UInt8] = [
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x06, 0x07, 0x08,
            0x09, 0x0A, 0x0B, 0x0C,
            0x0D, 0x0E, 0x0F, 0x10
        ]

        let uuid = RFC_9562.UUID.v8(customBytes: customBytes)

        #expect(uuid.version9562 == .v8)
        #expect(uuid.versionNumber == 8)
        #expect(uuid.variant == .rfc4122)
    }

    @Test("v8 preserves custom data except version/variant bits")
    func v8CustomData() throws {
        let customBytes: [UInt8] = [
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF
        ]

        let uuid = RFC_9562.UUID.v8(customBytes: customBytes)

        // Bytes 0-5 preserved
        for i in 0..<6 {
            #expect(uuid[i] == 0xFF)
        }

        // Byte 6: version bits set, low nibble preserved
        #expect(uuid[6] == 0x8F)  // Version 8 (0x80) | low nibble (0x0F)

        // Byte 7 preserved
        #expect(uuid[7] == 0xFF)

        // Byte 8: variant bits set, low 6 bits preserved
        #expect(uuid[8] == 0xBF)  // Variant (0x80) | low 6 bits (0x3F)

        // Bytes 9-15 preserved
        for i in 9..<16 {
            #expect(uuid[i] == 0xFF)
        }
    }

    @Test("v8 tuple-based generation")
    func v8Tuple() throws {
        let uuid = RFC_9562.UUID.v8(customBytes: (
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x06, 0x07, 0x08,
            0x09, 0x0A, 0x0B, 0x0C,
            0x0D, 0x0E, 0x0F, 0x10
        ))

        #expect(uuid.version9562 == .v8)
        #expect(uuid[0] == 0x01)
        #expect(uuid[15] == 0x10)
    }
}
