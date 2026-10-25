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
        let analytics = MockAnalyticsTracker()
        let sut = SignInViewModel(authenticator: authenticator, analytics: analytics)

        await sut.signIn()

        #expect(await authenticator.signInCount == 1)
        #expect(await analytics.events == [.signedIn])
        #expect(await authenticator.currentAccount() == makeUserAccount())
        #expect(sut.errorMessage == nil)
        #expect(sut.isSigningIn == false)
    }

    @Test func cancellingShowsNoError() async {
        let analytics = MockAnalyticsTracker()
        let sut = SignInViewModel(
            authenticator: MockAccountAuthenticator(signInResult: .failure(AccountError.signInCancelled)),
            analytics: analytics
        )

        await sut.signIn()

        #expect(await analytics.events.isEmpty)
        #expect(sut.errorMessage == nil)
        #expect(sut.isSigningIn == false)
    }

    @Test func failingShowsAnError() async {
        let sut = SignInViewModel(
            authenticator: MockAccountAuthenticator(signInResult: .failure(AccountError.signInFailed)),
            analytics: MockAnalyticsTracker()
        )

        await sut.signIn()

        #expect(sut.errorMessage == "Couldn't sign in with Google. Please try again.")
        #expect(sut.isSigningIn == false)
    }
}
