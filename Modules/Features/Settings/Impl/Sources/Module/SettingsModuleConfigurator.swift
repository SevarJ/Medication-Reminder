//
//  SettingsModuleConfigurator.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Settings

public enum SettingsModuleConfigurator {
    public static func makeModule() -> some SettingsModule {
        SettingsModuleImpl()
    }
}
