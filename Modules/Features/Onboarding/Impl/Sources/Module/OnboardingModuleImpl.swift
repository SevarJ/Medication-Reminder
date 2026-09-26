//
//  OnboardingModuleImpl.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppPreferences
import DependencyInjection
import Domain
import SwiftUI

struct OnboardingModuleImpl {
    private let medications: any MedicationRepository
    private let scheduler: any ReminderScheduling
    private let authorizer: any NotificationAuthorizing
    private let preferences: AppPreferences

    init(
        medications: any MedicationRepository = resolve(),
        scheduler: any ReminderScheduling = resolve(),
        authorizer: any NotificationAuthorizing = resolve(),
        preferences: AppPreferences = AppPreferences()
    ) {
        self.medications = medications
        self.scheduler = scheduler
        self.authorizer = authorizer
        self.preferences = preferences
    }

    @MainActor
    func shouldShowNotificationPriming() async -> Bool {
        await makePrimingModel().shouldPresent()
    }

    @MainActor
    func makeNotificationPrimingView(onFinish: @escaping () -> Void) -> some View {
        NotificationPrimingScreen(model: makePrimingModel(), onFinish: onFinish)
    }

    @MainActor
    private func makePrimingModel() -> NotificationPrimingModel {
        NotificationPrimingModel(
            authorizer: authorizer,
            syncReminder: SyncReminderUseCase(repository: medications, scheduler: scheduler),
            preferences: preferences
        )
    }
}
