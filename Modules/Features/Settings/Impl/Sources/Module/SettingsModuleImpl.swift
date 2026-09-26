//
//  SettingsModuleImpl.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppLocalization
import DependencyInjection
import Domain
import Foundation
import Settings
import SwiftUI

struct SettingsModuleImpl: SettingsModule {
    private let medications: any MedicationRepository
    private let scheduler: any ReminderScheduling
    private let authorizer: any NotificationAuthorizing
    private let languageStore: any LanguagePreferenceStoring
    private let bundle: Bundle

    init(
        medications: any MedicationRepository = resolve(),
        scheduler: any ReminderScheduling = resolve(),
        authorizer: any NotificationAuthorizing = resolve(),
        languageStore: any LanguagePreferenceStoring = UserDefaultsLanguageStore(),
        bundle: Bundle = .main
    ) {
        self.medications = medications
        self.scheduler = scheduler
        self.authorizer = authorizer
        self.languageStore = languageStore
        self.bundle = bundle
    }

    @MainActor
    func makeScreen(_ route: SettingsRoute) -> some View {
        switch route {
        case .settings:
            makeSettingsView()
        }
    }

    @MainActor
    private func makeSettingsView() -> some View {
        SettingsView(
            viewModel: SettingsViewModel(
                languageStore: languageStore,
                syncReminder: SyncReminderUseCase(repository: medications, scheduler: scheduler),
                authorizer: authorizer,
                appVersion: appVersion
            )
        )
    }

    private var appVersion: String {
        let info = bundle.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        let build = info?["CFBundleVersion"] as? String ?? ""

        return "\(version) (\(build))"
    }
}
