# swift-rfc-9562

Use this package when you need the parts of RFC 9562 that RFC 4122 lacks: making time-ordered version 7 UUIDs, making custom version 8 UUIDs, reading the timestamp out of a version 7 UUID, recognising versions 6 to 8, and the nil and max UUIDs. Start from `RFC_9562.UUID`, which is the same type as `RFC_4122.UUID`, so parsing and formatting come from swift-rfc-4122. If you want UUID generation already bound to the platform's random number generator, use swift-uuids.

## Laws

- `RFC_9562.Timestamp(unixMilliseconds:)` throws `RFC_9562.Timestamp.Error.outOfRange` unless the milliseconds fit in 48 bits, from 0 through 0xFFFF_FFFF_FFFF.
- `RFC_9562.UUID.v7(timestamp:using:)` puts the timestamp in the first 48 bits, big-endian, and fills the other 80 bits from the random source. It then overwrites the version and variant bits, which leaves 74 random bits.
- `RFC_9562.UUID.v7(timestamp:)` without a random source draws from the `RFC_4122.Random` in the current dependency scope.
- `RFC_9562.UUID.v8(customBytes:)` keeps every byte you pass except the version and variant bits, which it sets to version 8 and the RFC 4122 variant.
- `RFC_9562.UUID.unixMilliseconds` and `RFC_9562.UUID.unixSeconds` are nil for any UUID that is not version 7. `RFC_9562.UUID.unixSeconds` rounds down to whole seconds.
- `RFC_9562.UUID.version9562` is nil when the version field is 0 or above 8. That includes `RFC_9562.UUID.nil` and `RFC_9562.UUID.max`.
