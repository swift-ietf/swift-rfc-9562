public import RFC_4122

extension RFC_9562.UUID {

    public var unixMilliseconds: Int64? {
        guard versionNumber == 7 else { return nil }

        let b0 = Int64(bytes.0)
        let b1 = Int64(bytes.1)
        let b2 = Int64(bytes.2)
        let b3 = Int64(bytes.3)
        let b4 = Int64(bytes.4)
        let b5 = Int64(bytes.5)

        return (b0 << 40) | (b1 << 32) | (b2 << 24) | (b3 << 16) | (b4 << 8) | b5
    }

    public var unixSeconds: Int64? {
        guard let millis = unixMilliseconds else { return nil }
        return millis / 1000
    }
}
