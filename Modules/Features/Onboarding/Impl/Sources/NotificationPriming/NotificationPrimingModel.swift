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
    private let analytics: any AnalyticsTracking
    private let preferences: AppPreferences
    
    init(
        authorizer: any NotificationAuthorizing,
        syncReminder: SyncReminderUseCase,
        analytics: any AnalyticsTracking,
        preferences: AppPreferences = AppPreferences()
    ) {
        self.authorizer = authorizer
        self.syncReminder = syncReminder
        self.analytics = analytics
        self.preferences = preferences
    }
    
    func shouldPresent() async -> Bool {
        guard !preferences.hasShownNotificationPriming else { return false }
        
        return await authorizer.access() == .notDetermined
    }
    
    func allow() async {
        preferences.markNotificationPrimingShown()
        
        let isGranted = (try? await authorizer.requestAuthorization()) ?? false
        
        await analytics.track(.notificationPromptAnswered(isGranted ? .allowed : .denied))
        
        guard isGranted else { return }
        
        try? await syncReminder.execute()
    }
    
    func dismiss() async {
        preferences.markNotificationPrimingShown()
        await analytics.track(.notificationPromptAnswered(.postponed))
    }
}
