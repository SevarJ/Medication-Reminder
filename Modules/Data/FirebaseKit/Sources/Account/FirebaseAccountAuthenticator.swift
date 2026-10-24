//
//  FirebaseAccountAuthenticator.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseAuth
internal import FirebaseCore
internal import GoogleSignIn
internal import UIKit

/// `Auth.auth()` is looked up on every call, never stored, so nothing touches Firebase before `FirebaseApp.configure()`.
struct FirebaseAccountAuthenticator: AccountAuthenticating {
    func currentAccount() async -> UserAccount? {
        Auth.auth().currentUser.map(UserAccount.init(user:))
    }

    func accounts() -> AsyncStream<UserAccount?> {
        AsyncStream { continuation in
            nonisolated(unsafe) let handle = Auth.auth().addStateDidChangeListener { _, user in
                continuation.yield(user.map(UserAccount.init(user:)))
            }

            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }

    @MainActor
    func signInWithGoogle() async throws -> UserAccount {
        let google = try await signInToGoogle()
        let result = try await Auth.auth().signIn(with: Self.credential(for: google))

        return UserAccount(user: result.user)
    }

    @MainActor
    func signOut() async throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }

    @MainActor
    func reauthenticate() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AccountError.notSignedIn
        }

        let google: GIDGoogleUser

        if let restored = try? await GIDSignIn.sharedInstance.restorePreviousSignIn().refreshTokensIfNeeded() {
            google = restored
        }
        else {
            google = try await signInToGoogle()
        }

        try await user.reauthenticate(with: Self.credential(for: google))
    }

    @MainActor
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AccountError.notSignedIn
        }

        try await user.delete()
        try? await GIDSignIn.sharedInstance.disconnect()
    }

    @MainActor
    private func signInToGoogle() async throws -> GIDGoogleUser {
        guard let clientID = FirebaseApp.app()?.options.clientID, let presenter = Self.presenter else {
            throw AccountError.signInFailed
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        do {
            return try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter).user
        }
        catch let error as GIDSignInError where error.code == .canceled {
            throw AccountError.signInCancelled
        }
    }

    private static func credential(for google: GIDGoogleUser) throws -> AuthCredential {
        guard let idToken = google.idToken?.tokenString else {
            throw AccountError.signInFailed
        }

        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: google.accessToken.tokenString
        )
    }

    @MainActor
    private static var presenter: UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        var controller = scene?.keyWindow?.rootViewController

        while let presented = controller?.presentedViewController {
            controller = presented
        }

        return controller
    }
}
