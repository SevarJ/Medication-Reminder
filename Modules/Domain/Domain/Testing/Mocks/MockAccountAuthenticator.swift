//
//  MockAccountAuthenticator.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain

public actor MockAccountAuthenticator: AccountAuthenticating {
    public private(set) var signInCount = 0
    public private(set) var signOutCount = 0

    private var account: UserAccount?
    private let signInResult: Result<UserAccount, any Error>
    private let failsSignOut: Bool
    private let stream: AsyncStream<UserAccount?>
    private let continuation: AsyncStream<UserAccount?>.Continuation

    public init(
        account: UserAccount? = nil,
        signInResult: Result<UserAccount, any Error> = .success(makeUserAccount()),
        failsSignOut: Bool = false
    ) {
        self.account = account
        self.signInResult = signInResult
        self.failsSignOut = failsSignOut
        (stream, continuation) = AsyncStream.makeStream()
        continuation.yield(account)
    }

    public func currentAccount() async -> UserAccount? {
        account
    }

    public nonisolated func accounts() -> AsyncStream<UserAccount?> {
        stream
    }

    public func signInWithGoogle() async throws -> UserAccount {
        signInCount += 1

        let signedIn = try signInResult.get()
        account = signedIn
        continuation.yield(signedIn)

        return signedIn
    }

    public func signOut() async throws {
        signOutCount += 1

        if failsSignOut {
            throw PersistenceFailure()
        }

        account = nil
        continuation.yield(nil)
    }
}
