//
//  SettingsScreen.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Settings
import SwiftUI

public struct SettingsScreen: View {
    @State private var viewModel: SettingsViewModel

    public init(dependencies: SettingsDependencies) {
        _viewModel = State(
            initialValue: SettingsViewModel(
                languageStore: dependencies.languageStore,
                syncReminder: dependencies.syncReminder,
                authorizer: dependencies.authorizer,
                appVersion: dependencies.appVersion
            )
        )
    }

    public var body: some View {
        SettingsView(viewModel: viewModel)
    }
}
