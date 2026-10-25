//
//  ProSubscriptionTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

@testable import Domain
import Testing

struct ProSubscriptionTests {
    @Test func offersYearlyPlanFirst() {
        #expect(ProSubscription.productIDs == [ProSubscription.yearlyProductID, ProSubscription.monthlyProductID])
    }
}
