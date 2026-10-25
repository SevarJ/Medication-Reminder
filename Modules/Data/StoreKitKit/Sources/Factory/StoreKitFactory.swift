//
//  StoreKitFactory.swift
//  StoreKitKit
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain

enum StoreKitFactory {
    static func makeEntitlementProvider() -> any EntitlementProviding {
        StoreKitEntitlementProvider(productIDs: ProSubscription.productIDs)
    }
}
