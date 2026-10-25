//
//  StoreKitEntitlementProvider.swift
//  StoreKitKit
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
import StoreKit

final class StoreKitEntitlementProvider: EntitlementProviding {
    private let productIDs: Set<String>
    private let updates: Task<Void, Never>

    init(productIDs: some Sequence<String>) {
        self.productIDs = Set(productIDs)
        updates = Task.detached {
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
            }
        }
    }

    deinit {
        updates.cancel()
    }

    func currentEntitlement() async -> Entitlement {
        var purchases: [EntitledPurchase] = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchases.append(EntitledPurchase(productID: transaction.productID, revocationDate: transaction.revocationDate))
            }
        }

        return Entitlement(purchases: purchases, productIDs: productIDs)
    }

    func restorePurchases() async throws -> Entitlement {
        try await AppStore.sync()

        return await currentEntitlement()
    }
}
