import ProjectDescription

public extension Target {
    static func app(dependencies: [TargetDependency]) -> Target {
        .target(
            name: AppConfig.name,
            destinations: AppConfig.destinations,
            product: .app,
            bundleId: AppConfig.bundleId,
            deploymentTargets: AppConfig.deploymentTargets,
            infoPlist: .dictionary(urlTypes),
            buildableFolders: [
                .folder(.relativeToRoot("App/Sources")),
                .folder(.relativeToRoot("App/Resources")),
            ],
            entitlements: .file(path: .relativeToRoot("App/Medora.entitlements")),
            dependencies: dependencies,
            settings: .app,
            mergedBinaryType: .automatic,
            metadata: .metadata(tags: [AppConfig.compositionRootTag])
        )
    }
}

private let urlTypes: [String: Plist.Value] = [
    "CFBundleURLTypes": .array(
        ([AppConfig.urlScheme] + (AppConfig.googleSignInURLScheme.isEmpty ? [] : [AppConfig.googleSignInURLScheme]))
            .map { scheme in
                [
                    "CFBundleTypeRole": "Editor",
                    "CFBundleURLSchemes": [.string(scheme)],
                ]
            }
    ),
]

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
