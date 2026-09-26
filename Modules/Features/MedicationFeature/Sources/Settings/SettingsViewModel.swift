//
//  SettingsViewModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppFormatters
import AppLocalization
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class SettingsViewModel {
    public private(set) var language: AppLanguage
    public private(set) var notificationAccess: NotificationAccess?
    public var errorMessage: String?
    
    let appVersion: String
    
    private let changeLanguage: ChangeLanguageUseCase
    private let syncReminder: SyncReminderUseCase
    private let authorizer: any NotificationAuthorizing
    
    public init(
        languageStore: any LanguagePreferenceStoring,
        syncReminder: SyncReminderUseCase,
        authorizer: any NotificationAuthorizing,
        appVersion: String
    ) {
        self.language = languageStore.language
        self.changeLanguage = ChangeLanguageUseCase(store: languageStore, syncReminder: syncReminder)
        self.syncReminder = syncReminder
        self.authorizer = authorizer
        self.appVersion = appVersion
    }
    
    public func start() async {
        await refreshNotificationAccess()
    }
    
    func select(_ language: AppLanguage) async {
        guard language != self.language else { return }
        
        let previous = self.language
        self.language = language
        
        do {
            try await changeLanguage.execute(language)
        }
        catch {
            self.language = previous
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
    
    func refreshNotificationAccess() async {
        notificationAccess = await authorizer.access()
    }
    
    func enableNotifications() async {
        _ = try? await authorizer.requestAuthorization()
        
        await refreshNotificationAccess()
        
        guard notificationAccess == .authorized else { return }
        
        do {
            try await syncReminder.execute()
        }
        catch is ReminderError {
            await refreshNotificationAccess()
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
}
