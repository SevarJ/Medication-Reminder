//
//  DeleteAccountUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.10.26.
//

import DomainTesting
import Testing
@testable import Domain

struct DeleteAccountUseCaseTests {
    @Test func reauthenticatesThenDeletesDataAndAccount() async throws {
        let authenticator = MockAccountAuthenticator(account: makeUserAccount())
        let accountData = MockAccountDataRemoteStore()
        let sut = DeleteAccountUseCase(authenticator: authenticator, accountData: accountData)

        try await sut.execute()

        #expect(await authenticator.reauthenticateCount == 1)
        #expect(await accountData.deleteAllCount == 1)
        #expect(await authenticator.deleteAccountCount == 1)
        #expect(await authenticator.currentAccount() == nil)
    }

    @Test func keepsEverythingWhenReauthenticationFails() async {
        let authenticator = MockAccountAuthenticator(
            account: makeUserAccount(),
            reauthenticateError: AccountError.signInCancelled
        )
        let accountData = MockAccountDataRemoteStore()
        let sut = DeleteAccountUseCase(authenticator: authenticator, accountData: accountData)

        await #expect(throws: AccountError.signInCancelled) {
            try await sut.execute()
        }

        #expect(await accountData.deleteAllCount == 0)
        #expect(await authenticator.deleteAccountCount == 0)
    }

    @Test func keepsAccountWhenDataDeletionFails() async {
        let authenticator = MockAccountAuthenticator(account: makeUserAccount())
        let accountData = MockAccountDataRemoteStore(fails: true)
        let sut = DeleteAccountUseCase(authenticator: authenticator, accountData: accountData)

        await #expect(throws: PersistenceFailure.self) {
            try await sut.execute()
        }

        #expect(await authenticator.deleteAccountCount == 0)
        #expect(await authenticator.currentAccount() != nil)
    }
}
