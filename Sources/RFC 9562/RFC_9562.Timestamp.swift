extension RFC_9562 {

    public struct Timestamp: Sendable, Hashable {

        public let unixMilliseconds: Int64

        public init(unixMilliseconds: Int64) throws(Error) {
            guard (0...0xFFFF_FFFF_FFFF).contains(unixMilliseconds) else {
                throw .outOfRange
            }
            self.unixMilliseconds = unixMilliseconds
        }
    }
}

extension RFC_9562.Timestamp: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.unixMilliseconds < rhs.unixMilliseconds
    }
}
