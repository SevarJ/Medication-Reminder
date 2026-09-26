//
//  SettingsModule.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import SwiftUI

public enum SettingsModule {
    @MainActor
    public static func makeSettingsView() -> some View {
        SettingsModuleImpl().makeSettingsView()
    }
}
