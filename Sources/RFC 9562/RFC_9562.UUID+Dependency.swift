import Dependency
public import RFC_4122

extension RFC_9562.UUID {

    public static func v7(
        timestamp: RFC_9562.Timestamp
    ) throws(RFC_4122.Random.Error) -> Self {
        try v7(
            timestamp: timestamp,
            using: Dependency.Scope.current[RFC_4122.Random.self]
        )
    }
}
