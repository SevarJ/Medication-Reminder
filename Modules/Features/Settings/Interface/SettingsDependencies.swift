//
//  SettingsDependencies.swift
//  Settings
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppLocalization
import Domain

public struct SettingsDependencies {
    public let languageStore: any LanguagePreferenceStoring
    public let syncReminder: SyncReminderUseCase
    public let authorizer: any NotificationAuthorizing
    public let appVersion: String

    public init(
        languageStore: any LanguagePreferenceStoring,
        syncReminder: SyncReminderUseCase,
        authorizer: any NotificationAuthorizing,
        appVersion: String
    ) {
        self.languageStore = languageStore
        self.syncReminder = syncReminder
        self.authorizer = authorizer
        self.appVersion = appVersion
    }
}
