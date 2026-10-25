//
//  OnboardingFlow.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppPreferences
import Domain
import Onboarding

@MainActor
struct OnboardingFlow {
    private let preferences: AppPreferences
    private let priming: NotificationPrimingModel
    private let analytics: any AnalyticsTracking

    init(preferences: AppPreferences, priming: NotificationPrimingModel, analytics: any AnalyticsTracking) {
        self.preferences = preferences
        self.priming = priming
        self.analytics = analytics
    }

    func pendingRoute(at stage: OnboardingStage) async -> OnboardingRoute? {
        switch stage {
        case .beforeSignIn:
            return preferences.hasSeenIntroduction ? nil : .introduction
        case .afterSignIn:
            preferences.markIntroductionSeen()

            if await priming.shouldPresent() {
                return .notificationPriming
            }

            return nil
        }
    }

    func completeIntroduction() async {
        preferences.markIntroductionSeen()
        await analytics.track(.introductionCompleted)
    }
}
