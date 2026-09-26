import ProjectDescription
import ProjectDescriptionHelpers

let appLocalization = Module.foundation("AppLocalization", hasResources: true)
let appPreferences = Module.foundation("AppPreferences")
let diContainer = Module.foundation("DIContainer")
let designSystem = Module.foundation("DesignSystem", hasTests: false)

let domain = Module.domain("Domain", hasTesting: true)

let appFormatters = Module.shared("AppFormatters", dependencies: [domain, appLocalization], testDependencies: [domain, domain.testing], hasResources: true)

let persistence = Module.data("Persistence", dependencies: [domain], testDependencies: [domain])
let notificationsKit = Module.data("NotificationsKit", dependencies: [domain, appLocalization, appFormatters], testDependencies: [domain, domain.testing], hasResources: true)

let medicationFeature = Module.plainFeature(
    "MedicationFeature",
    dependencies: [domain, appLocalization, appPreferences, appFormatters, designSystem],
    testDependencies: [domain, domain.testing, appLocalization, appPreferences],
    hasResources: true
)

let modules = [appLocalization, appPreferences, diContainer, designSystem, domain, appFormatters, persistence, notificationsKit, medicationFeature]

let project = Project(
    name: AppConfig.name,
    options: .options(
        defaultKnownRegions: AppConfig.knownRegions,
        developmentRegion: "en",
        disableSynthesizedResourceAccessors: true
    ),
    settings: .project,
    targets: [.app(dependencies: modules.map(\.dependency))] + modules.flatMap(\.targets),
    schemes: [.app(testTargets: modules.compactMap(\.testTargetName))]
)
