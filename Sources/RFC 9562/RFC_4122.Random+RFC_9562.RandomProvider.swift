// RFC_4122.Random+RFC_9562.RandomProvider.swift
// Retroactive conformance enabling RFC_4122.Random for RFC 9562 UUID generation

public import RFC_4122

extension RFC_4122.Random: RFC_9562.RandomProvider {}
