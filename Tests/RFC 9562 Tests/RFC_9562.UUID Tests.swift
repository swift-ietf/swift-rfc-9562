import RFC_4122
import Testing

@testable import RFC_9562

extension RFC_9562.UUID {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension RFC_9562.UUID.Test.Unit {

    @Test
    func `Nil UUID is all zeros`() {
        let uuid = RFC_9562.UUID.nil
        #expect(uuid.description == "00000000-0000-0000-0000-000000000000")
        #expect(uuid.isNil)
        #expect(!uuid.isMax)
    }

    @Test
    func `Max UUID is all ones`() {
        let uuid = RFC_9562.UUID.max
        #expect(uuid.description == "ffffffff-ffff-ffff-ffff-ffffffffffff")
        #expect(uuid.isMax)
        #expect(!uuid.isNil)
    }

    @Test
    func `Regular UUID is neither nil nor max`() throws {
        let uuid = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        #expect(!uuid.isNil)
        #expect(!uuid.isMax)
    }

    @Test
    func `Detects v1`() throws {
        let uuid = try RFC_9562.UUID("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
        #expect(uuid.version9562 == .v1)
    }

    @Test
    func `Detects v4`() throws {
        let uuid = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        #expect(uuid.version9562 == .v4)
    }

    @Test
    func `Detects v6`() throws {
        let uuid = try RFC_9562.UUID("1ec9414c-232a-6b00-b3c8-9f6bdeced846")
        #expect(uuid.version9562 == .v6)
    }

    @Test
    func `Detects v7`() throws {
        let uuid = try RFC_9562.UUID("018f0b69-7c00-7000-8000-000000000000")
        #expect(uuid.version9562 == .v7)
    }

    @Test
    func `Detects v8`() throws {
        let uuid = try RFC_9562.UUID("00000000-0000-8000-8000-000000000000")
        #expect(uuid.version9562 == .v8)
    }

    @Test
    func `Extracts milliseconds from v7 UUID`() throws {
        let uuid = try RFC_9562.UUID("018e0b69-7c00-7000-8000-000000000000")
        #expect(uuid.unixMilliseconds == 0x018E_0B69_7C00)
    }

    @Test
    func `Extracts seconds from v7 UUID`() throws {
        let uuid = try RFC_9562.UUID("018e0b69-7c00-7000-8000-000000000000")
        guard let seconds = uuid.unixSeconds else {
            Issue.record("Expected seconds to be non-nil")
            return
        }
        #expect(seconds == 0x018E_0B69_7C00 / 1000)
    }

    @Test
    func `RFC_9562.UUID is RFC_4122.UUID`() throws {
        let rfc9562uuid: RFC_9562.UUID = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        let rfc4122uuid: RFC_4122.UUID = rfc9562uuid
        #expect(rfc4122uuid == rfc9562uuid)
    }
}

extension RFC_9562.UUID.Test.Unit {

    @Test
    func `RFC 9562: v7 timestamp extraction (known vector)`() throws {

        let uuid = try RFC_9562.UUID("017f22e2-79b0-7cc3-98c4-dc0c0c07398f")
        #expect(uuid.version9562 == .v7)
        #expect(uuid.variant == .rfc4122)
        #expect(uuid.unixMilliseconds == 0x017F_22E2_79B0)

        #expect(uuid.unixMilliseconds == 1_645_557_742_000)
    }

    @Test
    func `RFC 9562: v7 bit layout verification`() throws {

        let uuid = try RFC_9562.UUID("018ec3c5-d400-7000-8000-000000000000")
        #expect(uuid.version9562 == .v7)
        #expect(uuid.versionNumber == 7)
        #expect(uuid.variant == .rfc4122)

        #expect(uuid[0] == 0x01)
        #expect(uuid[1] == 0x8e)
        #expect(uuid[2] == 0xc3)
        #expect(uuid[3] == 0xc5)
        #expect(uuid[4] == 0xd4)
        #expect(uuid[5] == 0x00)

        #expect((uuid[6] & 0xF0) == 0x70)

        #expect((uuid[8] & 0xC0) == 0x80)
    }

    @Test
    func `RFC 9562: v6 structure verification`() throws {

        let uuid = try RFC_9562.UUID("1ec9414c-232a-6b00-b3c8-9f6bdeced846")
        #expect(uuid.version9562 == .v6)
        #expect(uuid.versionNumber == 6)
        #expect(uuid.variant == .rfc4122)

        #expect((uuid[6] & 0xF0) == 0x60)
    }

    @Test
    func `RFC 9562: v8 custom UUID`() throws {

        let uuid = try RFC_9562.UUID("320c3d4d-cc00-875b-8ec9-32d5f69181c0")
        #expect(uuid.version9562 == .v8)
        #expect(uuid.versionNumber == 8)
        #expect(uuid.variant == .rfc4122)

        #expect((uuid[6] & 0xF0) == 0x80)
    }

    @Test
    func `RFC 9562: Nil UUID byte verification`() {
        let uuid = RFC_9562.UUID.nil
        (0..<16).forEach { i in
            #expect(uuid[i] == 0x00)
        }

        #expect(uuid.version9562 == nil)
    }

    @Test
    func `RFC 9562: Max UUID byte verification`() {
        let uuid = RFC_9562.UUID.max
        (0..<16).forEach { i in
            #expect(uuid[i] == 0xFF)
        }

        #expect(uuid.version9562 == nil)
    }

    @Test
    func `v7 timestamp: Unix epoch (zero)`() throws {

        let uuid = try RFC_9562.UUID("00000000-0000-7000-8000-000000000000")
        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == 0)
    }

    @Test
    func `v7 timestamp: Maximum 48-bit value`() throws {

        let uuid = try RFC_9562.UUID("ffffffff-ffff-7000-8000-000000000000")
        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == 0xFFFF_FFFF_FFFF)

    }
}

extension RFC_9562.UUID.Test.`Edge Case` {
    @Test
    func `Returns nil timestamp for non-v7 UUID`() throws {
        let v4uuid = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        #expect(v4uuid.unixMilliseconds == nil)
        #expect(v4uuid.unixSeconds == nil)
    }

    @Test
    func `Returns nil version for invalid version number`() throws {

        let uuid = try RFC_9562.UUID("00000000-0000-0000-8000-000000000000")
        #expect(uuid.version9562 == nil)
        #expect(uuid.versionNumber == 0)
    }

    @Test
    func `Returns nil version for version 9+`() throws {

        let uuid = try RFC_9562.UUID("00000000-0000-9000-8000-000000000000")
        #expect(uuid.version9562 == nil)
        #expect(uuid.versionNumber == 9)
    }
}

private struct MockRandom: RFC_9562.RandomProvider {
    let pattern: UInt8
}

extension MockRandom {
    func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(Never) {
        for i in buffer.indices {
            buffer[i] = pattern
        }
    }
}

private struct SequentialRandom: RFC_9562.RandomProvider {
    let start: UInt8
}

extension SequentialRandom {
    func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(Never) {
        for (i, index) in buffer.indices.enumerated() {
            buffer[index] = start &+ UInt8(i)
        }
    }
}

extension RFC_9562.UUID.Test.Unit {

    @Test
    func `v7 generates correct version and variant`() throws {
        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: 1_645_557_742_000,
            using: MockRandom(pattern: 0xAA)
        )

        #expect(uuid.version9562 == .v7)
        #expect(uuid.versionNumber == 7)
        #expect(uuid.variant == .rfc4122)
    }

    @Test
    func `v7 encodes timestamp correctly`() throws {
        let timestamp: Int64 = 0x017F_22E2_79B0

        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: timestamp,
            using: MockRandom(pattern: 0x00)
        )

        #expect(uuid.unixMilliseconds == timestamp)

        #expect(uuid[0] == 0x01)
        #expect(uuid[1] == 0x7F)
        #expect(uuid[2] == 0x22)
        #expect(uuid[3] == 0xE2)
        #expect(uuid[4] == 0x79)
        #expect(uuid[5] == 0xB0)
    }

    @Test
    func `v7 preserves random bits in rand_a`() throws {
        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: 0,
            using: MockRandom(pattern: 0xFF)
        )

        #expect(uuid[6] == 0x7F)
    }

    @Test
    func `v7 preserves random bits in rand_b`() throws {
        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: 0,
            using: MockRandom(pattern: 0xFF)
        )

        #expect(uuid[8] == 0xBF)

        (9..<16).forEach { i in
            #expect(uuid[i] == 0xFF)
        }
    }

    @Test
    func `v7 with zero timestamp`() throws {
        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: 0,
            using: MockRandom(pattern: 0x00)
        )

        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == 0)

        (0..<6).forEach { i in
            #expect(uuid[i] == 0x00)
        }
    }

    @Test
    func `v7 with maximum 48-bit timestamp`() throws {
        let maxTimestamp: Int64 = 0xFFFF_FFFF_FFFF

        let uuid = try RFC_9562.UUID.v7(
            unixMilliseconds: maxTimestamp,
            using: MockRandom(pattern: 0x00)
        )

        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == maxTimestamp)

        (0..<6).forEach { i in
            #expect(uuid[i] == 0xFF)
        }
    }

    @Test
    func `v7 closure-based generation`() throws {
        let uuid = try RFC_9562.UUID.v7(unixMilliseconds: 1000) { buffer in
            for i in buffer.indices {
                buffer[i] = 0x55
            }
        }

        #expect(uuid.version9562 == .v7)
        #expect(uuid.unixMilliseconds == 1000)
    }

    @Test
    func `v8 generates correct version and variant`() throws {
        let customBytes: [UInt8] = [
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x06, 0x07, 0x08,
            0x09, 0x0A, 0x0B, 0x0C,
            0x0D, 0x0E, 0x0F, 0x10,
        ]

        let uuid = RFC_9562.UUID.v8(customBytes: customBytes)

        #expect(uuid.version9562 == .v8)
        #expect(uuid.versionNumber == 8)
        #expect(uuid.variant == .rfc4122)
    }

    @Test
    func `v8 preserves custom data except version/variant bits`() throws {
        let customBytes: [UInt8] = [
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF,
        ]

        let uuid = RFC_9562.UUID.v8(customBytes: customBytes)

        (0..<6).forEach { i in
            #expect(uuid[i] == 0xFF)
        }

        #expect(uuid[6] == 0x8F)

        #expect(uuid[7] == 0xFF)

        #expect(uuid[8] == 0xBF)

        (9..<16).forEach { i in
            #expect(uuid[i] == 0xFF)
        }
    }

    @Test
    func `v8 tuple-based generation`() throws {
        let uuid = RFC_9562.UUID.v8(
            customBytes: (
                0x01, 0x02, 0x03, 0x04,
                0x05, 0x06, 0x07, 0x08,
                0x09, 0x0A, 0x0B, 0x0C,
                0x0D, 0x0E, 0x0F, 0x10
            )
        )

        #expect(uuid.version9562 == .v8)
        #expect(uuid[0] == 0x01)
        #expect(uuid[15] == 0x10)
    }
}
