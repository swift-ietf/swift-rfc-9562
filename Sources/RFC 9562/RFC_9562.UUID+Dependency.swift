// RFC_9562.UUID+Dependency.swift
// Convenience UUID v7 generation using dependency-resolved random provider

public import RFC_4122
import Dependency_Primitives

// MARK: - Version 7 (Time-ordered, resolved from context)

extension RFC_9562.UUID {
    /// Generates a version 7 UUID using the random provider from dependency scope.
    ///
    /// Resolves ``RFC_4122/Random`` from ``Dependency/Scope/current`` to obtain
    /// random bytes. The default `liveValue` uses `SystemRandomNumberGenerator`.
    ///
    /// ```swift
    /// let uuid = try RFC_9562.UUID.v7(unixMilliseconds: 1645557742000)
    /// ```
    ///
    /// - Parameter unixMilliseconds: Unix epoch timestamp in milliseconds.
    /// - Returns: A version 7 UUID.
    /// - Throws: ``RFC_4122/Random/Error`` if random byte generation fails.
    public static func v7(
        unixMilliseconds: Int64
    ) throws(RFC_4122.Random.Error) -> Self {
        try v7(
            unixMilliseconds: unixMilliseconds,
            using: Dependency.Scope.current[RFC_4122.Random.self]
        )
    }
}
