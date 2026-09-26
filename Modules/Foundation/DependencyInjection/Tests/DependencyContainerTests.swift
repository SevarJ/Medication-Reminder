//
//  DependencyContainerTests.swift
//  DependencyInjectionTests
//
//  Created by Sevar Jafarli on 26.09.26.
//

@testable import DependencyInjection
import Testing

private protocol Greeter: Sendable {
    var greeting: String { get }
}

private final class EnglishGreeter: Greeter {
    let greeting = "Hello"
}

private final class AzerbaijaniGreeter: Greeter {
    let greeting = "Salam"
}

private final class Announcer: Sendable {
    let greeter: any Greeter

    init(greeter: any Greeter) {
        self.greeter = greeter
    }
}

struct DependencyContainerTests {
    private let sut = DependencyContainer()

    @Test func resolvesRegisteredDependency() {
        sut.register((any Greeter).self) { EnglishGreeter() }

        #expect(sut.resolve((any Greeter).self).greeting == "Hello")
    }

    @Test func factoryCreatesNewInstanceOnEveryResolve() {
        sut.register(EnglishGreeter.self) { EnglishGreeter() }

        #expect(sut.resolve(EnglishGreeter.self) !== sut.resolve(EnglishGreeter.self))
    }

    @Test func singletonIsCreatedOnce() {
        sut.registerSingleton(EnglishGreeter.self) { EnglishGreeter() }

        #expect(sut.resolve(EnglishGreeter.self) === sut.resolve(EnglishGreeter.self))
    }

    @Test func laterRegistrationReplacesEarlierOne() {
        sut.registerSingleton((any Greeter).self) { EnglishGreeter() }
        _ = sut.resolve((any Greeter).self)

        sut.registerSingleton((any Greeter).self) { AzerbaijaniGreeter() }

        #expect(sut.resolve((any Greeter).self).greeting == "Salam")
    }

    @Test func reportsWhetherDependencyIsRegistered() {
        #expect(!sut.isRegistered((any Greeter).self))

        sut.register((any Greeter).self) { EnglishGreeter() }

        #expect(sut.isRegistered((any Greeter).self))
    }

    @Test func singletonCanResolveItsOwnDependencies() {
        let container = sut
        container.register((any Greeter).self) { AzerbaijaniGreeter() }
        container.registerSingleton(Announcer.self) { Announcer(greeter: container.resolve()) }

        #expect(container.resolve(Announcer.self).greeter.greeting == "Salam")
    }
}
