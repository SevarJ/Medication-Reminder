//
//  ChangeLanguageUseCase.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import Domain

struct ChangeLanguageUseCase: Sendable {
    private let store: any LanguagePreferenceStoring
    private let syncReminder: SyncReminderUseCase
    
    init(
        store: any LanguagePreferenceStoring,
        syncReminder: SyncReminderUseCase
    ) {
        self.store = store
        self.syncReminder = syncReminder
    }
    
    func execute(_ language: AppLanguage) async throws {
        guard language != store.language else { return }
        
        store.save(language)
        
        do {
            try await syncReminder.execute()
        }
        catch is ReminderError {
            return
        }
    }
}
