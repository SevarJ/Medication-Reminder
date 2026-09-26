import ProjectDescription

public struct Module: Sendable {
    public let name: String
    public let dependencies: [TargetDependency]
    public let testDependencies: [TargetDependency]
    public let hasResources: Bool
    public let hasTests: Bool

    public static func module(
        _ name: String,
        dependencies: [Module] = [],
        testDependencies: [Module] = [],
        hasResources: Bool = false,
        hasTests: Bool = true
    ) -> Module {
        Module(
            name: name,
            dependencies: dependencies.map(\.dependency),
            testDependencies: testDependencies.map(\.dependency),
            hasResources: hasResources,
            hasTests: hasTests
        )
    }

    public var dependency: TargetDependency {
        .target(name: name)
    }

    public var testTargetName: String? {
        hasTests ? "\(name)Tests" : nil
    }

    public var targets: [Target] {
        hasTests ? [framework, tests] : [framework]
    }

    private var framework: Target {
        .target(
            name: name,
            destinations: AppConfig.destinations,
            product: .framework,
            bundleId: "\(AppConfig.bundleId).\(name)",
            deploymentTargets: AppConfig.deploymentTargets,
            buildableFolders: frameworkFolders,
            dependencies: dependencies,
            settings: .module
        )
    }

    private var frameworkFolders: [BuildableFolder] {
        let sources: BuildableFolder = .folder(.relativeToRoot("Modules/\(name)/Sources"))
        let resources: BuildableFolder = .folder(.relativeToRoot("Modules/\(name)/Resources"))
        return hasResources ? [sources, resources] : [sources]
    }

    private var tests: Target {
        .target(
            name: "\(name)Tests",
            destinations: AppConfig.destinations,
            product: .unitTests,
            bundleId: "\(AppConfig.bundleId).\(name)Tests",
            deploymentTargets: AppConfig.deploymentTargets,
            buildableFolders: [
                .folder(.relativeToRoot("Modules/\(name)/Tests")),
            ],
            dependencies: [dependency] + testDependencies,
            settings: .module
        )
    }
}
