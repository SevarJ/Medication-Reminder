//
//  NotificationPrimingModel.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppPreferences
import Domain

@MainActor
final class NotificationPrimingModel {
    private let authorizer: any NotificationAuthorizing
    private let syncReminder: SyncReminderUseCase
    private let preferences: AppPreferences
    
    init(
        authorizer: any NotificationAuthorizing,
        syncReminder: SyncReminderUseCase,
        preferences: AppPreferences = AppPreferences()
    ) {
        self.authorizer = authorizer
        self.syncReminder = syncReminder
        self.preferences = preferences
    }
    
    func shouldPresent() async -> Bool {
        guard !preferences.hasShownNotificationPriming else { return false }
        
        return await authorizer.access() == .notDetermined
    }
    
    func allow() async {
        preferences.markNotificationPrimingShown()
        
        let isGranted = (try? await authorizer.requestAuthorization()) ?? false
        
        guard isGranted else { return }
        
        try? await syncReminder.execute()
    }
    
    func dismiss() {
        preferences.markNotificationPrimingShown()
    }
}
