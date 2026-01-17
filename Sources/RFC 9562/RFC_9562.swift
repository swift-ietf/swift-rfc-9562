// RFC_9562.swift
// Universally Unique IDentifiers (UUIDs)
// https://www.rfc-editor.org/rfc/rfc9562

public import RFC_4122

/// Namespace for RFC 9562: Universally Unique IDentifiers (UUIDs).
///
/// RFC 9562 obsoletes RFC 4122 and adds three new UUID versions:
/// - Version 6: Reordered time-based UUID
/// - Version 7: Unix epoch time-based UUID (recommended for new applications)
/// - Version 8: Custom UUID with application-specific data
///
/// This module re-exports the core `UUID` type from RFC 4122 and extends it
/// with the additional version definitions and utilities from RFC 9562.
public enum RFC_9562 {}

extension RFC_9562 {
    /// Re-export RFC 4122 UUID as the canonical UUID type.
    ///
    /// RFC 9562 builds on the UUID type defined in RFC 4122.
    /// All UUIDs (v1-v8) share the same 128-bit structure.
    public typealias UUID = RFC_4122.UUID
}
