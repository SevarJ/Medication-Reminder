import ProjectDescription

public struct Feature: Sendable {
    public let name: String
    let interfaceDependencies: [TargetDependency]
    let implementationDependencies: [TargetDependency]
    let testDependencies: [TargetDependency]

    public static func feature(
        _ name: String,
        interfaceDependencies: [Module] = [],
        dependencies: [Module] = [],
        features: [Feature] = [],
        testDependencies: [Module] = []
    ) -> Feature {
        require(interfaceDependencies, in: [.foundation, .domain], for: "\(name) interface")
        require(dependencies, in: [.foundation, .domain, .shared], for: "\(name)Impl")

        return Feature(
            name: name,
            interfaceDependencies: interfaceDependencies.map(\.dependency),
            implementationDependencies: [.target(name: name)]
                + features.map(\.interface)
                + dependencies.map(\.dependency),
            testDependencies: testDependencies.map(\.dependency)
        )
    }

    private static func require(_ modules: [Module], in layers: Set<Layer>, for target: String) {
        for module in modules where !layers.contains(module.layer) {
            fatalError("\(target) cannot depend on \(module.name) (\(module.layer.rawValue))")
        }
    }

    public var interface: TargetDependency {
        .target(name: name)
    }

    public var implementation: TargetDependency {
        .target(name: "\(name)Impl")
    }

    public var testTargetName: String {
        "\(name)ImplTests"
    }

    public var targets: [Target] {
        [
            .framework(
                name: name,
                folders: [.folder(.relativeToRoot("\(path)/Interface"))],
                dependencies: interfaceDependencies
            ),
            .framework(
                name: "\(name)Impl",
                folders: [
                    .folder(.relativeToRoot("\(path)/Impl/Sources")),
                    .folder(.relativeToRoot("\(path)/Impl/Resources")),
                ],
                dependencies: implementationDependencies
            ),
            .unitTests(
                name: testTargetName,
                folder: .folder(.relativeToRoot("\(path)/Tests")),
                dependencies: [implementation] + testDependencies
            ),
        ]
    }

    private var path: String {
        "Modules/Features/\(name)"
    }
}
