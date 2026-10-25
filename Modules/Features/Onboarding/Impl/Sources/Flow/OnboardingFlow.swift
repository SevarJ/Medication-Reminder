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
    private let entitlements: any EntitlementProviding
    private let analytics: any AnalyticsTracking

    init(
        preferences: AppPreferences,
        priming: NotificationPrimingModel,
        entitlements: any EntitlementProviding,
        analytics: any AnalyticsTracking
    ) {
        self.preferences = preferences
        self.priming = priming
        self.entitlements = entitlements
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

            if await shouldOfferPro() {
                return .paywall
            }

            return nil
        }
    }

    func completeIntroduction() async {
        preferences.markIntroductionSeen()
        await analytics.track(.introductionCompleted)
    }

    private func shouldOfferPro() async -> Bool {
        guard preferences.isPaywallEnabled, !preferences.hasShownPaywall else { return false }

        return await entitlements.currentEntitlement() == .free
    }
}
