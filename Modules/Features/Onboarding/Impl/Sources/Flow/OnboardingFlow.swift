//
//  OnboardingFlow.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppPreferences
import Onboarding

@MainActor
struct OnboardingFlow {
    private let preferences: AppPreferences
    private let priming: NotificationPrimingModel

    init(preferences: AppPreferences, priming: NotificationPrimingModel) {
        self.preferences = preferences
        self.priming = priming
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
}
