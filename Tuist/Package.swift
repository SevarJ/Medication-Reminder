// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MedReminder",
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.19.2"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "10.0.0"),
    ]
)
