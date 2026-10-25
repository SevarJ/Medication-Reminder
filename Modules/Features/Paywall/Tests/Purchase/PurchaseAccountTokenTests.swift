//
//  PurchaseAccountTokenTests.swift
//  PaywallImplTests
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation
import Testing
@testable import PaywallImpl

struct PurchaseAccountTokenTests {
    @Test func matchesNameBasedUUIDVersionFive() throws {
        let dns = try #require(UUID(uuidString: "6BA7B810-9DAD-11D1-80B4-00C04FD430C8"))

        #expect(PurchaseAccountToken.make(for: "python.org", in: dns).uuidString == "886313E1-3B8A-5372-9B90-0C9AEE199E5D")
    }

    @Test func staysTheSameForAnAccount() {
        #expect(PurchaseAccountToken.make(for: "user-1") == PurchaseAccountToken.make(for: "user-1"))
    }

    @Test func differsBetweenAccounts() {
        #expect(PurchaseAccountToken.make(for: "user-1") != PurchaseAccountToken.make(for: "user-2"))
    }
}
