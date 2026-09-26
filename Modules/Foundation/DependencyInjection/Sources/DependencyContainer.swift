//
//  DependencyContainer.swift
//  DependencyInjection
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Foundation

public final class DependencyContainer: @unchecked Sendable {
    public static let shared = DependencyContainer()

    private enum Registration {
        case factory(@Sendable () -> Any)
        case singleton(@Sendable () -> Any)
    }

    private let lock = NSLock()
    private var registrations: [ObjectIdentifier: Registration] = [:]
    private var singletons: [ObjectIdentifier: Any] = [:]

    public init() {}

    public func register<Dependency>(
        _ type: Dependency.Type = Dependency.self,
        factory: @escaping @Sendable () -> Dependency
    ) {
        store(.factory(factory), for: type)
    }

    public func registerSingleton<Dependency>(
        _ type: Dependency.Type = Dependency.self,
        factory: @escaping @Sendable () -> Dependency
    ) {
        store(.singleton(factory), for: type)
    }

    public func isRegistered<Dependency>(_ type: Dependency.Type) -> Bool {
        lock.withLock { registrations[ObjectIdentifier(type)] != nil }
    }

    public func resolve<Dependency>(_ type: Dependency.Type = Dependency.self) -> Dependency {
        let key = ObjectIdentifier(type)
        let (registration, cached) = lock.withLock { (registrations[key], singletons[key]) }

        if let cached = cached as? Dependency {
            return cached
        }

        guard let registration else {
            fatalError("\(Dependency.self) is not registered")
        }

        switch registration {
        case .factory(let make):
            return cast(make())
        case .singleton(let make):
            let instance: Dependency = cast(make())

            return lock.withLock {
                if let existing = singletons[key] as? Dependency {
                    return existing
                }

                singletons[key] = instance
                return instance
            }
        }
    }

    private func store(_ registration: Registration, for type: Any.Type) {
        let key = ObjectIdentifier(type)

        lock.withLock {
            registrations[key] = registration
            singletons[key] = nil
        }
    }

    private func cast<Dependency>(_ value: Any) -> Dependency {
        guard let dependency = value as? Dependency else {
            fatalError("\(Dependency.self) registration returned \(type(of: value))")
        }

        return dependency
    }
}

public func resolve<Dependency>(_ type: Dependency.Type = Dependency.self) -> Dependency {
    DependencyContainer.shared.resolve(type)
}
