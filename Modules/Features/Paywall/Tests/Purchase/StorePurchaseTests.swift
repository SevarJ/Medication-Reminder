//
//  StorePurchaseTests.swift
//  PaywallImplTests
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
import StoreKit
import Testing
@testable import PaywallImpl

struct StorePurchaseTests {
    private struct StoreFailure: Error {}

    @Test func mapsCancelledPurchase() async {
        #expect(await StorePurchase.outcome(of: .success(.userCancelled)) == .cancelled)
    }

    @Test func mapsPendingPurchase() async {
        #expect(await StorePurchase.outcome(of: .success(.pending)) == .pending)
    }

    @Test func mapsStoreError() async {
        #expect(await StorePurchase.outcome(of: .failure(StoreFailure())) == .failed)
    }
}
