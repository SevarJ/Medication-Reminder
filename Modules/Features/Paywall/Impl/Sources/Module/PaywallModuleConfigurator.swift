//
//  PaywallModuleConfigurator.swift
//  PaywallImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Paywall

public enum PaywallModuleConfigurator {
    public static func makeModule() -> some PaywallModule {
        PaywallModuleImpl()
    }
}
