//
//  EntitledPurchase.swift
//  StoreKitKit
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
import Foundation

struct EntitledPurchase: Equatable {
    let productID: String
    let revocationDate: Date?
}

extension Entitlement {
    init(purchases: [EntitledPurchase], productIDs: Set<String>) {
        let isActive = purchases.contains { productIDs.contains($0.productID) && $0.revocationDate == nil }

        self = isActive ? .pro : .free
    }
}
