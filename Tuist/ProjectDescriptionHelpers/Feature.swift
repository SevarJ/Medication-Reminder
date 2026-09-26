import ProjectDescription

public struct Feature: Sendable {
    public let name: String
    let dependencies: [TargetDependency]
    let testDependencies: [TargetDependency]

    public static func feature(
        _ name: String,
        dependencies: [Module] = [],
        testDependencies: [Module] = []
    ) -> Feature {
        for module in dependencies where module.layer == .data {
            fatalError("\(name)Impl cannot depend on \(module.name) (\(module.layer.rawValue)); features reach data through use cases")
        }

        return Feature(
            name: name,
            dependencies: [.target(name: name)] + dependencies.map(\.dependency),
            testDependencies: testDependencies.map(\.dependency)
        )
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
                folders: [.folder(.relativeToRoot("\(path)/Interface/Sources"))],
                dependencies: []
            ),
            .framework(
                name: "\(name)Impl",
                folders: [
                    .folder(.relativeToRoot("\(path)/Impl/Sources")),
                    .folder(.relativeToRoot("\(path)/Impl/Resources")),
                ],
                dependencies: dependencies
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
