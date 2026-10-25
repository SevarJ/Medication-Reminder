//
//  SignInViewModel.swift
//  AccountImpl
//
//  Created by Sevar Jafarli on 01.10.26.
//

import AppFormatters
import Domain
import Observation

@MainActor
@Observable
final class SignInViewModel {
    private(set) var isSigningIn = false
    var errorMessage: String?

    private let authenticator: any AccountAuthenticating
    private let analytics: any AnalyticsTracking

    init(authenticator: any AccountAuthenticating, analytics: any AnalyticsTracking) {
        self.authenticator = authenticator
        self.analytics = analytics
    }

    func signIn() async {
        guard !isSigningIn else { return }

        isSigningIn = true
        defer { isSigningIn = false }

        do {
            _ = try await authenticator.signInWithGoogle()
            await analytics.track(.signedIn)
        }
        catch AccountError.signInCancelled {
            return
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
}
