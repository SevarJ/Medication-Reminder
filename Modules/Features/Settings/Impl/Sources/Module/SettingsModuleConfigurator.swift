//
//  SettingsModuleConfigurator.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Paywall
import Settings

public enum SettingsModuleConfigurator {
    public static func makeModule(paywall: some PaywallModule) -> some SettingsModule {
        SettingsModuleImpl(paywall: paywall)
    }
}
