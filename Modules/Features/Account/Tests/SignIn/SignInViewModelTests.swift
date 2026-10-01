//
//  SignInViewModelTests.swift
//  AccountImplTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import DomainTesting
import Testing
@testable import AccountImpl

@MainActor
struct SignInViewModelTests {
    @Test func signingInAsksTheAuthenticator() async {
        let authenticator = MockAccountAuthenticator()
        let sut = SignInViewModel(authenticator: authenticator)

        await sut.signIn()

        #expect(await authenticator.signInCount == 1)
        #expect(await authenticator.currentAccount() == makeUserAccount())
        #expect(sut.errorMessage == nil)
        #expect(sut.isSigningIn == false)
    }

    @Test func cancellingShowsNoError() async {
        let sut = SignInViewModel(
            authenticator: MockAccountAuthenticator(signInResult: .failure(AccountError.signInCancelled))
        )

        await sut.signIn()

        #expect(sut.errorMessage == nil)
        #expect(sut.isSigningIn == false)
    }

    @Test func failingShowsAnError() async {
        let sut = SignInViewModel(
            authenticator: MockAccountAuthenticator(signInResult: .failure(AccountError.signInFailed))
        )

        await sut.signIn()

        #expect(sut.errorMessage == "Something went wrong. Please try again.")
        #expect(sut.isSigningIn == false)
    }
}
