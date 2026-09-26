import Testing
@testable import DIContainer

private protocol Greeter: Sendable {
    var greeting: String { get }
}

private struct LiveGreeter: Greeter {
    let greeting = "live"
}

private struct MockGreeter: Greeter {
    let greeting: String
}

private enum GreeterKey: DependencyKey {
    static let liveValue: any Greeter = LiveGreeter()
}

private enum SecondaryGreeterKey: DependencyKey {
    static let liveValue: any Greeter = MockGreeter(greeting: "secondary")
}

private enum CounterKey: DependencyKey {
    static let liveValue: Int = 0
}

@Test("Resolves the live value when nothing is registered")
func resolvesLiveValueWhenNotRegistered() {
    let container = DependencyContainer()

    #expect(container.resolve(GreeterKey.self).greeting == "live")
    #expect(container.resolve(CounterKey.self) == 0)
}

@Test("Resolves the registered value once registered")
func resolvesRegisteredValue() {
    var container = DependencyContainer()
    container.register(GreeterKey.self, MockGreeter(greeting: "mock"))

    #expect(container.resolve(GreeterKey.self).greeting == "mock")
}

@Test("The latest registration replaces the previous one")
func latestRegistrationWins() {
    var container = DependencyContainer()
    container.register(CounterKey.self, 1)
    container.register(CounterKey.self, 2)

    #expect(container.resolve(CounterKey.self) == 2)
}

@Test("Distinct keys sharing a value type do not collide")
func distinctKeysWithSameValueTypeDoNotCollide() {
    var container = DependencyContainer()
    container.register(GreeterKey.self, MockGreeter(greeting: "first"))

    #expect(container.resolve(GreeterKey.self).greeting == "first")
    #expect(container.resolve(SecondaryGreeterKey.self).greeting == "secondary")
}

@Test("registering(_:_:) returns a copy and leaves the original untouched")
func registeringReturnsCopyWithoutMutatingOriginal() {
    let original = DependencyContainer()
    let derived = original.registering(CounterKey.self, 42)

    #expect(original.resolve(CounterKey.self) == 0)
    #expect(derived.resolve(CounterKey.self) == 42)
}

@Test("registering(_:_:) can be chained")
func registeringChains() {
    let container = DependencyContainer()
        .registering(CounterKey.self, 7)
        .registering(GreeterKey.self, MockGreeter(greeting: "chained"))

    #expect(container.resolve(CounterKey.self) == 7)
    #expect(container.resolve(GreeterKey.self).greeting == "chained")
}

@Test("Copies stay independent because the container is a value type")
func copiesAreIndependent() {
    var first = DependencyContainer()
    first.register(CounterKey.self, 1)

    var second = first
    second.register(CounterKey.self, 99)

    #expect(first.resolve(CounterKey.self) == 1)
    #expect(second.resolve(CounterKey.self) == 99)
}

@Test("The container can cross an actor boundary")
func crossesActorBoundary() async {
    actor Consumer {
        func greeting(from container: DependencyContainer) -> String {
            container.resolve(GreeterKey.self).greeting
        }
    }

    let container = DependencyContainer()
        .registering(GreeterKey.self, MockGreeter(greeting: "actor"))

    let result = await Consumer().greeting(from: container)
    #expect(result == "actor")
}
