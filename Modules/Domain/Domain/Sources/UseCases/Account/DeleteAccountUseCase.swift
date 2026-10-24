//
//  DeleteAccountUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.10.26.
//

public struct DeleteAccountUseCase: Sendable {
    private let authenticator: any AccountAuthenticating
    private let accountData: any AccountDataRemoteStore

    public init(authenticator: any AccountAuthenticating, accountData: any AccountDataRemoteStore) {
        self.authenticator = authenticator
        self.accountData = accountData
    }

    public func execute() async throws {
        try await authenticator.reauthenticate()
        try await accountData.deleteAll()
        try await authenticator.deleteAccount()
    }
}
