//
//  EntitledPurchaseTests.swift
//  StoreKitKitTests
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
import Foundation
import Testing
@testable import StoreKitKit

struct EntitledPurchaseTests {
    private let productIDs: Set<String> = ["pro.yearly", "pro.monthly"]

    @Test func isFreeWithoutPurchases() {
        #expect(Entitlement(purchases: [], productIDs: productIDs) == .free)
    }

    @Test func isProWithAnActiveSubscription() {
        let purchases = [EntitledPurchase(productID: "pro.monthly", revocationDate: nil)]

        #expect(Entitlement(purchases: purchases, productIDs: productIDs) == .pro)
    }

    @Test func ignoresRefundedSubscription() {
        let purchases = [EntitledPurchase(productID: "pro.yearly", revocationDate: Date())]

        #expect(Entitlement(purchases: purchases, productIDs: productIDs) == .free)
    }

    @Test func ignoresProductsOutsideTheSubscription() {
        let purchases = [EntitledPurchase(productID: "tip.small", revocationDate: nil)]

        #expect(Entitlement(purchases: purchases, productIDs: productIDs) == .free)
    }
}
