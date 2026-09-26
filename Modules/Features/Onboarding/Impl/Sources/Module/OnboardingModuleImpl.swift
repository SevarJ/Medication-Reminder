//
//  OnboardingModuleImpl.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppPreferences
import DependencyInjection
import Domain
import Onboarding
import SwiftUI

struct OnboardingModuleImpl: OnboardingModule {
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
    func pendingRoute() async -> OnboardingRoute? {
        await makePrimingModel().shouldPresent() ? .notificationPriming : nil
    }

    @MainActor
    func makeScreen(_ route: OnboardingRoute) -> some View {
        switch route {
        case .notificationPriming:
            NotificationPrimingScreen(model: makePrimingModel())
        }
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
