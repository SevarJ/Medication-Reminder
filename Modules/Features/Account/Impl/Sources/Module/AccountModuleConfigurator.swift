//
//  AccountModuleConfigurator.swift
//  AccountImpl
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Account

public enum AccountModuleConfigurator {
    public static func makeModule() -> some AccountModule {
        AccountModuleImpl()
    }
}
