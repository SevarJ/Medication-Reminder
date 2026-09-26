import ProjectDescription

public enum Layer: String, Sendable {
    case foundation = "Foundation"
    case domain = "Domain"
    case shared = "Shared"
    case data = "Data"
    case features = "Features"
}

public struct Module: Sendable {
    public let name: String
    public let layer: Layer
    let dependencies: [TargetDependency]
    let testDependencies: [TargetDependency]
    let hasResources: Bool
    let hasTests: Bool
    let hasTesting: Bool

    public static func foundation(
        _ name: String,
        dependencies: [Module] = [],
        hasResources: Bool = false,
        hasTests: Bool = true
    ) -> Module {
        Module(
            name: name,
            layer: .foundation,
            dependencies: dependencies,
            allowedLayers: [.foundation],
            hasResources: hasResources,
            hasTests: hasTests
        )
    }

    public static func domain(_ name: String, hasTesting: Bool = false) -> Module {
        Module(
            name: name,
            layer: .domain,
            dependencies: [],
            allowedLayers: [],
            hasTesting: hasTesting
        )
    }

    public static func shared(
        _ name: String,
        dependencies: [Module] = [],
        testDependencies: [Module] = [],
        hasResources: Bool = false
    ) -> Module {
        Module(
            name: name,
            layer: .shared,
            dependencies: dependencies,
            testDependencies: testDependencies,
            allowedLayers: [.foundation, .domain],
            hasResources: hasResources
        )
    }

    public static func data(
        _ name: String,
        dependencies: [Module] = [],
        testDependencies: [Module] = [],
        hasResources: Bool = false
    ) -> Module {
        Module(
            name: name,
            layer: .data,
            dependencies: dependencies,
            testDependencies: testDependencies,
            allowedLayers: [.foundation, .domain, .shared],
            hasResources: hasResources
        )
    }

    public static func plainFeature(
        _ name: String,
        dependencies: [Module] = [],
        testDependencies: [Module] = [],
        hasResources: Bool = false
    ) -> Module {
        Module(
            name: name,
            layer: .features,
            dependencies: dependencies,
            testDependencies: testDependencies,
            allowedLayers: [.foundation, .domain, .shared],
            hasResources: hasResources
        )
    }

    private init(
        name: String,
        layer: Layer,
        dependencies: [Module],
        testDependencies: [Module] = [],
        allowedLayers: Set<Layer>,
        hasResources: Bool = false,
        hasTests: Bool = true,
        hasTesting: Bool = false
    ) {
        for dependency in dependencies where !allowedLayers.contains(dependency.layer) {
            fatalError("\(name) (\(layer.rawValue)) cannot depend on \(dependency.name) (\(dependency.layer.rawValue))")
        }

        self.name = name
        self.layer = layer
        self.dependencies = dependencies.map(\.dependency)
        self.testDependencies = testDependencies.map(\.dependency)
        self.hasResources = hasResources
        self.hasTests = hasTests
        self.hasTesting = hasTesting
    }

    private init(testingFor module: Module) {
        name = "\(module.name)Testing"
        layer = module.layer
        dependencies = [module.dependency]
        testDependencies = []
        hasResources = false
        hasTests = false
        hasTesting = false
    }

    public var dependency: TargetDependency {
        .target(name: name)
    }

    public var testing: Module {
        guard hasTesting else {
            fatalError("\(name) has no testing module")
        }

        return Module(testingFor: self)
    }

    public var testTargetName: String? {
        hasTests ? "\(name)Tests" : nil
    }

    public var targets: [Target] {
        [framework]
            + (hasTesting ? [testingFramework] : [])
            + (hasTests ? [tests] : [])
    }

    private var path: String {
        "Modules/\(layer.rawValue)/\(name)"
    }

    private var framework: Target {
        let sources: BuildableFolder = .folder(.relativeToRoot("\(path)/Sources"))
        let resources: BuildableFolder = .folder(.relativeToRoot("\(path)/Resources"))

        return .framework(
            name: name,
            folders: hasResources ? [sources, resources] : [sources],
            dependencies: dependencies
        )
    }

    private var testingFramework: Target {
        .framework(
            name: "\(name)Testing",
            folders: [.folder(.relativeToRoot("\(path)/Testing"))],
            dependencies: [dependency]
        )
    }

    private var tests: Target {
        .unitTests(
            name: "\(name)Tests",
            folder: .folder(.relativeToRoot("\(path)/Tests")),
            dependencies: [dependency]
                + (hasTesting ? [.target(name: "\(name)Testing")] : [])
                + testDependencies
        )
    }
}

extension Target {
    static func framework(
        name: String,
        folders: [BuildableFolder],
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: name,
            destinations: AppConfig.destinations,
            product: .framework,
            bundleId: "\(AppConfig.bundleId).\(name)",
            deploymentTargets: AppConfig.deploymentTargets,
            buildableFolders: folders,
            dependencies: dependencies,
            settings: .module
        )
    }

    static func unitTests(
        name: String,
        folder: BuildableFolder,
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: name,
            destinations: AppConfig.destinations,
            product: .unitTests,
            bundleId: "\(AppConfig.bundleId).\(name)",
            deploymentTargets: AppConfig.deploymentTargets,
            buildableFolders: [folder],
            dependencies: dependencies,
            settings: .module
        )
    }
}
