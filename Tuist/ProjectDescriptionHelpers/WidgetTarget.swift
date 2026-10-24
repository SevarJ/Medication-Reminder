import ProjectDescription

public extension Target {
    static func widget(dependencies: [TargetDependency]) -> Target {
        .target(
            name: AppConfig.widgetName,
            destinations: AppConfig.destinations,
            product: .appExtension,
            bundleId: "\(AppConfig.bundleId).widget",
            deploymentTargets: AppConfig.deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": .string(AppConfig.name),
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
                ],
            ]),
            buildableFolders: [
                .folder(.relativeToRoot("Widget/Sources")),
                .folder(.relativeToRoot("Widget/Resources")),
            ],
            entitlements: .file(path: .relativeToRoot("Widget/MedoraWidget.entitlements")),
            dependencies: dependencies,
            settings: .widget,
            mergedBinaryType: .automatic
        )
    }
}
