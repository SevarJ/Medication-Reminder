//
//  MockEntitlementProvider.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain

public actor MockEntitlementProvider: EntitlementProviding {
    public private(set) var restoreCount = 0

    private var entitlement: Entitlement
    private let restoredEntitlement: Entitlement?

    public init(entitlement: Entitlement = .free, restoresTo restoredEntitlement: Entitlement? = .free) {
        self.entitlement = entitlement
        self.restoredEntitlement = restoredEntitlement
    }

    public func setEntitlement(_ entitlement: Entitlement) {
        self.entitlement = entitlement
    }

    public func currentEntitlement() async -> Entitlement {
        entitlement
    }

    public func restorePurchases() async throws -> Entitlement {
        restoreCount += 1

        guard let restoredEntitlement else { throw PersistenceFailure() }

        entitlement = restoredEntitlement

        return entitlement
    }
}
