import ProjectDescription

public extension Target {
    static func app(modules: [Module]) -> Target {
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
            dependencies: modules.map(\.dependency),
            settings: .app,
            mergedBinaryType: .automatic
        )
    }
}

public extension Scheme {
    static func app(modules: [Module]) -> Scheme {
        .scheme(
            name: AppConfig.name,
            buildAction: .buildAction(targets: [.target(AppConfig.name)]),
            testAction: .targets(
                modules.compactMap(\.testTargetName).map { .testableTarget(target: .target($0)) }
            ),
            runAction: .runAction(executable: .target(AppConfig.name))
        )
    }
}
