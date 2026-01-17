// RFC_9562.UUID Tests.swift

import Testing
import Testing_Extras
import RFC_4122
@testable import RFC_9562

extension RFC_9562.UUID {
    #TestSuites
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

// MARK: - Edge Cases

extension RFC_9562.UUID.Test.EdgeCase {
    @Test("Returns nil timestamp for non-v7 UUID")
    func nilForNonV7() throws {
        let v4uuid = try RFC_9562.UUID("550e8400-e29b-41d4-a716-446655440000")
        #expect(v4uuid.unixMilliseconds == nil)
        #expect(v4uuid.unixSeconds == nil)
    }
}
