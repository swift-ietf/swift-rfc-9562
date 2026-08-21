public import RFC_4122

extension RFC_9562 {

    public enum Version: UInt8, Sendable, Hashable {

        case v1 = 1

        case v2 = 2

        case v3 = 3

        case v4 = 4

        case v5 = 5

        case v6 = 6

        case v7 = 7

        case v8 = 8
    }
}

extension RFC_9562.UUID {

    public var version9562: RFC_9562.Version? {
        RFC_9562.Version(rawValue: versionNumber)
    }
}
