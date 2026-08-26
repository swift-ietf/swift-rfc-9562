import Dependency
public import RFC_4122

extension RFC_9562.UUID {

    public static func v7(
        unixMilliseconds: Int64
    ) throws(RFC_4122.Random.Error) -> Self {
        try v7(
            unixMilliseconds: unixMilliseconds,
            using: Dependency.Scope.current[RFC_4122.Random.self]
        )
    }
}
