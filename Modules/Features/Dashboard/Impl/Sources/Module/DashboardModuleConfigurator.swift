//
//  DashboardModuleConfigurator.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Dashboard

public enum DashboardModuleConfigurator {
    public static func makeModule() -> some DashboardModule {
        DashboardModuleImpl()
    }
}
