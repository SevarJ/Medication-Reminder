import ProjectDescription
import ProjectDescriptionHelpers

let domain = Module.module("Domain", hasResources: true)
let diContainer = Module.module("DIContainer")
let designSystem = Module.module("DesignSystem", hasTests: false)
let persistence = Module.module("Persistence", dependencies: [domain], testDependencies: [domain])
let notificationsKit = Module.module("NotificationsKit", dependencies: [domain], testDependencies: [domain], hasResources: true)
let medicationFeature = Module.module("MedicationFeature", dependencies: [domain, designSystem], testDependencies: [domain], hasResources: true)

let modules = [domain, diContainer, designSystem, persistence, notificationsKit, medicationFeature]

let project = Project(
    name: AppConfig.name,
    options: .options(
        defaultKnownRegions: AppConfig.knownRegions,
        developmentRegion: "en",
        disableSynthesizedResourceAccessors: true
    ),
    settings: .project,
    targets: [.app(modules: modules)] + modules.flatMap(\.targets),
    schemes: [.app(modules: modules)]
)
