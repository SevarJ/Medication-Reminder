//
//  PaywallViewModelTests.swift
//  PaywallImplTests
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
import DomainTesting
import Testing
@testable import PaywallImpl

@MainActor
struct PaywallViewModelTests {
    private let analytics = MockAnalyticsTracker()

    private func makeSUT(
        entitlements: MockEntitlementProvider = MockEntitlementProvider(),
        account: UserAccount? = makeUserAccount()
    ) -> PaywallViewModel {
        PaywallViewModel(entitlements: entitlements, authenticator: MockAccountAuthenticator(account: account), analytics: analytics)
    }

    @Test func tracksBeingShown() async {
        await makeSUT().appear()

        #expect(await analytics.events == [.paywallShown])
    }

    @Test func tiesPurchasesToTheSignedInAccount() async {
        let sut = makeSUT(account: makeUserAccount(id: "uid-42"))

        await sut.appear()

        #expect(sut.accountToken == PurchaseAccountToken.make(for: "uid-42"))
    }

    @Test func leavesPurchasesUntiedWithoutAnAccount() async {
        let sut = makeSUT(account: nil)

        await sut.appear()

        #expect(sut.accountToken == nil)
    }

    @Test func finishesAfterPurchase() async {
        let sut = makeSUT()

        await sut.finishPurchase(.purchased(productID: ProSubscription.yearlyProductID))

        #expect(sut.isFinished)
        #expect(sut.notice == nil)
        #expect(await analytics.events == [.purchaseFinished(.purchased(productID: ProSubscription.yearlyProductID))])
    }

    @Test func staysOpenWhenPurchaseIsCancelled() async {
        let sut = makeSUT()

        await sut.finishPurchase(.cancelled)

        #expect(!sut.isFinished)
        #expect(sut.notice == nil)
        #expect(await analytics.events == [.purchaseFinished(.cancelled)])
    }

    @Test func explainsPendingPurchase() async {
        let sut = makeSUT()

        await sut.finishPurchase(.pending)

        #expect(!sut.isFinished)
        #expect(sut.notice == .pending)
    }

    @Test func reportsFailedPurchase() async {
        let sut = makeSUT()

        await sut.finishPurchase(.failed)

        #expect(!sut.isFinished)
        #expect(sut.notice == .failed)
    }

    @Test func finishesWhenRestoreFindsPro() async {
        let entitlements = MockEntitlementProvider(restoresTo: .pro)
        let sut = makeSUT(entitlements: entitlements)

        await sut.restore()

        #expect(sut.isFinished)
        #expect(!sut.isRestoring)
        #expect(await entitlements.restoreCount == 1)
        #expect(await analytics.events == [.purchasesRestored(.restored)])
    }

    @Test func explainsWhenThereIsNothingToRestore() async {
        let sut = makeSUT(entitlements: MockEntitlementProvider(restoresTo: .free))

        await sut.restore()

        #expect(!sut.isFinished)
        #expect(sut.notice == .nothingToRestore)
        #expect(await analytics.events == [.purchasesRestored(.nothingToRestore)])
    }

    @Test func reportsFailedRestore() async {
        let sut = makeSUT(entitlements: MockEntitlementProvider(restoresTo: nil))

        await sut.restore()

        #expect(!sut.isFinished)
        #expect(sut.notice == .failed)
        #expect(await analytics.events == [.purchasesRestored(.failed)])
    }

    @Test func closingFinishesWithoutTracking() async {
        let sut = makeSUT()

        sut.close()

        #expect(sut.isFinished)
        #expect(await analytics.events.isEmpty)
    }
}
