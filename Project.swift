import ProjectDescription
import ProjectDescriptionHelpers

let appLocalization = Module.foundation("AppLocalization", hasResources: true)
let appPreferences = Module.foundation("AppPreferences")
let dependencyInjection = Module.foundation("DependencyInjection")
let designSystem = Module.foundation("DesignSystem", hasTests: false)

let domain = Module.domain("Domain", hasTesting: true)

let appFormatters = Module.shared("AppFormatters", dependencies: [domain, appLocalization], testDependencies: [domain, domain.testing], hasResources: true)

let persistence = Module.data("Persistence", dependencies: [domain, dependencyInjection], testDependencies: [domain, dependencyInjection])
let notificationsKit = Module.data(
    "NotificationsKit",
    dependencies: [domain, appLocalization, appFormatters, dependencyInjection],
    testDependencies: [domain, domain.testing, dependencyInjection],
    hasResources: true
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

let modules = [appLocalization, appPreferences, dependencyInjection, designSystem, domain, appFormatters, persistence, notificationsKit]
let features = [onboarding, dashboard, settings]

let project = Project(
    name: AppConfig.name,
    options: .options(
        defaultKnownRegions: AppConfig.knownRegions,
        developmentRegion: "en",
        disableSynthesizedResourceAccessors: true
    ),
    settings: .project,
    targets: [.app(dependencies: modules.map(\.dependency) + features.flatMap { [$0.interface, $0.implementation] })]
        + modules.flatMap(\.targets)
        + features.flatMap(\.targets),
    schemes: [.app(testTargets: modules.compactMap(\.testTargetName) + features.map(\.testTargetName))]
)
