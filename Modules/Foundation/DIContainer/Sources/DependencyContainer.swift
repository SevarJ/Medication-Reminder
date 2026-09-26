//
//  DependencyContainer.swift
//  DIContainer
//
//  Created by Sevar Jafarli on 01.08.26.
//

public struct DependencyContainer: Sendable {
    private var overrides: [ObjectIdentifier: any Sendable]

    public init() {
        self.overrides = [:]
    }

    public subscript<Key: DependencyKey>(key: Key.Type) -> Key.Value {
        get {
            guard let stored = overrides[ObjectIdentifier(key)],
                  let value = stored as? Key.Value
            else {
                return Key.liveValue
            }
            return value
        }
        set {
            overrides[ObjectIdentifier(key)] = newValue
        }
    }

    public mutating func register<Key: DependencyKey>(
        _ key: Key.Type,
        _ value: Key.Value
    ) {
        self[key] = value
    }

    public func resolve<Key: DependencyKey>(_ key: Key.Type) -> Key.Value {
        self[key]
    }

    public func registering<Key: DependencyKey>(
        _ key: Key.Type,
        _ value: Key.Value
    ) -> Self {
        var copy = self
        copy.register(key, value)
        return copy
    }
}
