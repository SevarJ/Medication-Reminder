//
//  EntitlementProviding.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

public protocol EntitlementProviding: Sendable {
    func currentEntitlement() async -> Entitlement
    func restorePurchases() async throws -> Entitlement
}
