import ProjectDescription
import ProjectDescriptionHelpers

let appLocalization = Module.foundation("AppLocalization", hasResources: true)
let appPreferences = Module.foundation("AppPreferences")
let dependencyInjection = Module.foundation("DependencyInjection")
let designSystem = Module.foundation("DesignSystem", hasTests: false)
let widgetSnapshot = Module.foundation("WidgetSnapshot")

let domain = Module.domain("Domain", hasTesting: true)

let appFormatters = Module.shared("AppFormatters", dependencies: [domain, appLocalization], testDependencies: [domain, domain.testing], hasResources: true)

let persistence = Module.data("Persistence", dependencies: [domain, dependencyInjection], testDependencies: [domain, dependencyInjection])
let notificationsKit = Module.data(
    "NotificationsKit",
    dependencies: [domain, appLocalization, appFormatters, dependencyInjection],
    testDependencies: [domain, domain.testing, dependencyInjection],
    hasResources: true
)

let dataSync = Module.data("DataSync", dependencies: [domain, dependencyInjection], testDependencies: [domain, domain.testing, dependencyInjection])

let widgetBridge = Module.data(
    "WidgetBridge",
    dependencies: [domain, appLocalization, appFormatters, dependencyInjection, widgetSnapshot],
    testDependencies: [domain, domain.testing, appLocalization, widgetSnapshot]
)

let firebaseKit = Module.data(
    "FirebaseKit",
    dependencies: [domain, dependencyInjection],
    packages: ["FirebaseCore", "FirebaseAuth", "FirebaseFirestore", "FirebaseAnalyticsCore", "FirebaseCrashlytics", "FirebasePerformance", "GoogleSignIn"],
    hasTests: false
)

let account = Feature.feature(
    "Account",
    dependencies: [domain, appLocalization, appFormatters, dependencyInjection, designSystem],
    testDependencies: [domain, domain.testing]
)

let onboarding = Feature.feature(
    "Onboarding",
    dependencies: [domain, appLocalization, appPreferences, dependencyInjection, designSystem],
    testDependencies: [domain, domain.testing, appPreferences]
)

let dashboard = Feature.feature(
    "Dashboard",
    dependencies: [domain, appLocalization, appPreferences, appFormatters, dependencyInjection, designSystem],
    testDependencies: [domain, domain.testing]
)

let settings = Feature.feature(
    "Settings",
    dependencies: [domain, appLocalization, appPreferences, appFormatters, dependencyInjection, designSystem],
    testDependencies: [domain, domain.testing, appLocalization]
)

let modules = [appLocalization, appPreferences, dependencyInjection, designSystem, widgetSnapshot, domain, appFormatters, persistence, notificationsKit, firebaseKit, dataSync, widgetBridge]
let features = [account, onboarding, dashboard, settings]

let project = Project(
    name: AppConfig.name,
    options: .options(
        defaultKnownRegions: AppConfig.knownRegions,
        developmentRegion: "en",
        disableSynthesizedResourceAccessors: true
    ),
    settings: .project,
    targets: [
        .app(dependencies: modules.map(\.dependency) + features.flatMap { [$0.interface, $0.implementation] } + [.target(name: AppConfig.widgetName)]),
        .widget(dependencies: [widgetSnapshot, appLocalization, designSystem].map(\.dependency)),
    ]
        + modules.flatMap(\.targets)
        + features.flatMap(\.targets),
    schemes: [.app(testTargets: modules.compactMap(\.testTargetName) + features.map(\.testTargetName))]
)
