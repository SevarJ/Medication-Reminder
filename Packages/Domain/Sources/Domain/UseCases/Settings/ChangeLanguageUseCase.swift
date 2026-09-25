//
//  ChangeLanguageUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

public struct ChangeLanguageUseCase: Sendable {
    private let store: any LanguagePreferenceStoring
    private let syncReminder: SyncReminderUseCase
    
    public init(
        store: any LanguagePreferenceStoring,
        syncReminder: SyncReminderUseCase
    ) {
        self.store = store
        self.syncReminder = syncReminder
    }
    
    public func execute(_ language: AppLanguage) async throws {
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
