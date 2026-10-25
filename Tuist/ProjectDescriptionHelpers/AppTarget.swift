import ProjectDescription

public extension Target {
    static func app(dependencies: [TargetDependency]) -> Target {
        .target(
            name: AppConfig.name,
            destinations: AppConfig.destinations,
            product: .app,
            bundleId: AppConfig.bundleId,
            deploymentTargets: AppConfig.deploymentTargets,
            infoPlist: .dictionary(urlTypes.merging(analyticsPrivacy) { $1 }),
            buildableFolders: [
                .folder(.relativeToRoot("App/Sources")),
                .folder(.relativeToRoot("App/Resources")),
            ],
            entitlements: .file(path: .relativeToRoot("App/Medora.entitlements")),
            scripts: [.crashlyticsSymbolsUpload],
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

private let analyticsPrivacy: [String: Plist.Value] = [
    "GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS": false,
    "GOOGLE_ANALYTICS_REGISTRATION_WITH_AD_NETWORK_ENABLED": false,
    "GOOGLE_ANALYTICS_IDFV_COLLECTION_ENABLED": false,
]

private let crashlyticsPath = "Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics"

private extension TargetScript {
    static let crashlyticsSymbolsUpload: TargetScript = .post(
        script: "\"${SRCROOT}/\(crashlyticsPath)/run\"",
        name: "Upload dSYMs to Crashlytics",
        inputPaths: [
            .glob(.relativeToRoot("\(crashlyticsPath)/run")),
            .glob(.relativeToRoot("\(crashlyticsPath)/upload-symbols")),
        ],
        inputFileListPaths: [.relativeToRoot("\(crashlyticsPath)/CrashlyticsInputFiles.xcfilelist")],
        basedOnDependencyAnalysis: false
    )
}

public extension Scheme {
    static func app(testTargets: [String]) -> Scheme {
        .scheme(
            name: AppConfig.name,
            buildAction: .buildAction(targets: [.target(AppConfig.name)]),
            testAction: .targets(testTargets.map { .testableTarget(target: .target($0)) }),
            runAction: .runAction(
                executable: .target(AppConfig.name),
                options: .options(storeKitConfigurationPath: .relativeToRoot("App/Medora.storekit"))
            )
        )
    }
}
