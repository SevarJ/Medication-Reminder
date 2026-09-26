import ProjectDescription

public extension Target {
    static func app(dependencies: [TargetDependency]) -> Target {
        .target(
            name: AppConfig.name,
            destinations: AppConfig.destinations,
            product: .app,
            bundleId: AppConfig.bundleId,
            deploymentTargets: AppConfig.deploymentTargets,
            infoPlist: nil,
            buildableFolders: [
                .folder(.relativeToRoot("App/Sources")),
                .folder(.relativeToRoot("App/Resources")),
            ],
            entitlements: .file(path: .relativeToRoot("App/MedReminder.entitlements")),
            dependencies: dependencies,
            settings: .app,
            mergedBinaryType: .automatic
        )
    }
}

public extension Scheme {
    static func app(testTargets: [String]) -> Scheme {
        .scheme(
            name: AppConfig.name,
            buildAction: .buildAction(targets: [.target(AppConfig.name)]),
            testAction: .targets(testTargets.map { .testableTarget(target: .target($0)) }),
            runAction: .runAction(executable: .target(AppConfig.name))
        )
    }
}
