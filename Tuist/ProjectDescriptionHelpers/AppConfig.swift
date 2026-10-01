import ProjectDescription

public enum AppConfig {
    public static let name = "Medora"
    public static let bundleId = "com.sevarjafarli.medora"
    /// `REVERSED_CLIENT_ID` from the untracked `GoogleService-Info.plist`; Google Sign-In returns to the app through it.
    /// `make generate` hands it over as `TUIST_GOOGLE_SIGN_IN_URL_SCHEME`, so it is never committed.
    public static let googleSignInURLScheme = Environment.googleSignInUrlScheme.getString(default: "")
    public static let destinations: Destinations = [.iPhone]
    public static let deploymentTargets: DeploymentTargets = .iOS("17.0")
    public static let knownRegions = ["en", "Base", "az", "ru"]
    public static let compositionRootTag = "composition-root"
}
