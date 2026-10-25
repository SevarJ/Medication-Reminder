//
//  StoreKitConfigurator.swift
//  StoreKitKit
//
//  Created by Sevar Jafarli on 25.10.26.
//

import DependencyInjection
import Domain

public enum StoreKitConfigurator {
    public static func setup(in container: DependencyContainer = .shared) {
        let entitlements = StoreKitFactory.makeEntitlementProvider()

        container.registerSingleton((any EntitlementProviding).self) { entitlements }
    }
}
