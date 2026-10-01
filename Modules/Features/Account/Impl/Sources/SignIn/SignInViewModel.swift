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

    init(authenticator: any AccountAuthenticating) {
        self.authenticator = authenticator
    }

    func signIn() async {
        guard !isSigningIn else { return }

        isSigningIn = true
        defer { isSigningIn = false }

        do {
            _ = try await authenticator.signInWithGoogle()
        }
        catch AccountError.signInCancelled {
            return
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
}
