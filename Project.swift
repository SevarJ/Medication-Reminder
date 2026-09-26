import ProjectDescription
import ProjectDescriptionHelpers

let diContainer = Module.foundation("DIContainer")
let designSystem = Module.foundation("DesignSystem", hasTests: false)

let domain = Module.domain("Domain", hasResources: true)

let persistence = Module.data("Persistence", dependencies: [domain], testDependencies: [domain])
let notificationsKit = Module.data("NotificationsKit", dependencies: [domain], testDependencies: [domain], hasResources: true)

let medicationFeature = Module.plainFeature("MedicationFeature", dependencies: [domain, designSystem], testDependencies: [domain], hasResources: true)

let modules = [diContainer, designSystem, domain, persistence, notificationsKit, medicationFeature]

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
