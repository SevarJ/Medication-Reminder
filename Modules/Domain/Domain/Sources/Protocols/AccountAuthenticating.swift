//
//  AccountAuthenticating.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

public protocol AccountAuthenticating: Sendable {
    func currentAccount() async -> UserAccount?
    /// Emits the current account straight away, then again after every sign-in and sign-out.
    func accounts() -> AsyncStream<UserAccount?>
    func signInWithGoogle() async throws -> UserAccount
    func signOut() async throws
}
