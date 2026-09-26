import ProjectDescription

public enum AppConfig {
    public static let name = "MedReminder"
    public static let bundleId = "com.example.MedReminder"
    public static let destinations: Destinations = [.iPhone]
    public static let deploymentTargets: DeploymentTargets = .iOS("17.0")
    public static let knownRegions = ["en", "Base", "az", "ru"]
    public static let compositionRootTag = "composition-root"
}
