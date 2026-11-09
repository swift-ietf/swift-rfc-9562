extension RFC_9562 {

    public struct Timestamp: Sendable, Hashable, Comparable {

        public let unixMilliseconds: Int64

        public init(unixMilliseconds: Int64) throws(Error) {
            guard (0...0xFFFF_FFFF_FFFF).contains(unixMilliseconds) else {
                throw .outOfRange
            }
            self.unixMilliseconds = unixMilliseconds
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.unixMilliseconds < rhs.unixMilliseconds
        }
    }
}
