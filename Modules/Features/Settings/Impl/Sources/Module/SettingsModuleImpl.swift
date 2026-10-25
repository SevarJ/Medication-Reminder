//
//  SettingsModuleImpl.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppLocalization
import AppPreferences
import DependencyInjection
import Domain
import Foundation
import Paywall
import Settings
import SwiftUI

struct SettingsModuleImpl<Paywall: PaywallModule>: SettingsModule {
    private let paywall: Paywall
    private let medications: any MedicationRepository
    private let scheduler: any ReminderScheduling
    private let authorizer: any NotificationAuthorizing
    private let authenticator: any AccountAuthenticating
    private let accountData: any AccountDataRemoteStore
    private let entitlements: any EntitlementProviding
    private let languageStore: any LanguagePreferenceStoring
    private let preferences: AppPreferences
    private let bundle: Bundle

    init(
        paywall: Paywall,
        medications: any MedicationRepository = resolve(),
        scheduler: any ReminderScheduling = resolve(),
        authorizer: any NotificationAuthorizing = resolve(),
        authenticator: any AccountAuthenticating = resolve(),
        accountData: any AccountDataRemoteStore = resolve(),
        entitlements: any EntitlementProviding = resolve(),
        languageStore: any LanguagePreferenceStoring = UserDefaultsLanguageStore(),
        preferences: AppPreferences = AppPreferences(),
        bundle: Bundle = .main
    ) {
        self.paywall = paywall
        self.medications = medications
        self.scheduler = scheduler
        self.authorizer = authorizer
        self.authenticator = authenticator
        self.accountData = accountData
        self.entitlements = entitlements
        self.languageStore = languageStore
        self.preferences = preferences
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
            paywall: paywall,
            viewModel: SettingsViewModel(
                languageStore: languageStore,
                syncReminder: SyncReminderUseCase(repository: medications, scheduler: scheduler),
                authorizer: authorizer,
                authenticator: authenticator,
                deleteAccount: DeleteAccountUseCase(authenticator: authenticator, accountData: accountData),
                entitlements: entitlements,
                preferences: preferences,
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
