//
//  StorePurchase.swift
//  PaywallImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
import StoreKit

enum StorePurchase {
    static func outcome(of result: Result<Product.PurchaseResult, any Error>) async -> PurchaseOutcome {
        guard case .success(let purchase) = result else { return .failed }

        switch purchase {
        case .success(.verified(let transaction)):
            await transaction.finish()

            return .purchased(productID: transaction.productID)
        case .success(.unverified):
            return .failed
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .failed
        }
    }
}
