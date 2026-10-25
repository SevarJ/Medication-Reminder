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
    private let analytics: any AnalyticsTracking
    private let preferences: AppPreferences

    init(
        medications: any MedicationRepository = resolve(),
        scheduler: any ReminderScheduling = resolve(),
        authorizer: any NotificationAuthorizing = resolve(),
        analytics: any AnalyticsTracking = resolve(),
        preferences: AppPreferences = AppPreferences()
    ) {
        self.medications = medications
        self.scheduler = scheduler
        self.authorizer = authorizer
        self.analytics = analytics
        self.preferences = preferences
    }

    @MainActor
    func pendingRoute(at stage: OnboardingStage) async -> OnboardingRoute? {
        await makeFlow().pendingRoute(at: stage)
    }

    @MainActor
    @ViewBuilder
    func makeScreen(_ route: OnboardingRoute, onFinish: @escaping () -> Void) -> some View {
        switch route {
        case .introduction:
            IntroductionView {
                Task {
                    await makeFlow().completeIntroduction()
                    onFinish()
                }
            }
        case .notificationPriming:
            NotificationPrimingScreen(model: makePrimingModel(), onFinish: onFinish)
        }
    }

    @MainActor
    private func makeFlow() -> OnboardingFlow {
        OnboardingFlow(preferences: preferences, priming: makePrimingModel(), analytics: analytics)
    }

    @MainActor
    private func makePrimingModel() -> NotificationPrimingModel {
        NotificationPrimingModel(
            authorizer: authorizer,
            syncReminder: SyncReminderUseCase(repository: medications, scheduler: scheduler),
            analytics: analytics,
            preferences: preferences
        )
    }
}
