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
import Paywall
import SwiftUI

struct OnboardingModuleImpl<Paywall: PaywallModule>: OnboardingModule {
    private let paywall: Paywall
    private let medications: any MedicationRepository
    private let scheduler: any ReminderScheduling
    private let authorizer: any NotificationAuthorizing
    private let entitlements: any EntitlementProviding
    private let analytics: any AnalyticsTracking
    private let preferences: AppPreferences

    init(
        paywall: Paywall,
        medications: any MedicationRepository = resolve(),
        scheduler: any ReminderScheduling = resolve(),
        authorizer: any NotificationAuthorizing = resolve(),
        entitlements: any EntitlementProviding = resolve(),
        analytics: any AnalyticsTracking = resolve(),
        preferences: AppPreferences = AppPreferences()
    ) {
        self.paywall = paywall
        self.medications = medications
        self.scheduler = scheduler
        self.authorizer = authorizer
        self.entitlements = entitlements
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
        case .paywall:
            paywall.makeScreen(.onboarding) {
                preferences.markPaywallShown()
                onFinish()
            }
        }
    }

    @MainActor
    private func makeFlow() -> OnboardingFlow {
        OnboardingFlow(preferences: preferences, priming: makePrimingModel(), entitlements: entitlements, analytics: analytics)
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
