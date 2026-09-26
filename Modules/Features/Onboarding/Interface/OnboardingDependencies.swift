//
//  OnboardingDependencies.swift
//  Onboarding
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppPreferences
import Domain

public struct OnboardingDependencies {
    public let authorizer: any NotificationAuthorizing
    public let syncReminder: SyncReminderUseCase
    public let preferences: AppPreferences

    public init(
        authorizer: any NotificationAuthorizing,
        syncReminder: SyncReminderUseCase,
        preferences: AppPreferences
    ) {
        self.authorizer = authorizer
        self.syncReminder = syncReminder
        self.preferences = preferences
    }
}
