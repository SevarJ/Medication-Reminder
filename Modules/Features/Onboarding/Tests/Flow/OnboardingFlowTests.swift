//
//  OnboardingFlowTests.swift
//  OnboardingImplTests
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppPreferences
import Domain
import DomainTesting
import Foundation
import Testing
@testable import OnboardingImpl

@MainActor
struct OnboardingFlowTests {
    private let defaults: UserDefaults
    private let preferences: AppPreferences
    private let analytics = MockAnalyticsTracker()
    
    init() throws {
        let suiteName = "OnboardingFlowTests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suiteName))
        preferences = AppPreferences(defaults: defaults)
    }
    
    private func makeSUT(access: NotificationAccess = .notDetermined, entitlement: Entitlement = .free) -> OnboardingFlow {
        OnboardingFlow(
            preferences: preferences,
            priming: NotificationPrimingModel(
                authorizer: MockNotificationAuthorizer(access: access),
                syncReminder: SyncReminderUseCase(repository: MockMedicationRepository(), scheduler: MockReminderScheduler()),
                analytics: analytics,
                preferences: preferences
            ),
            entitlements: MockEntitlementProvider(entitlement: entitlement),
            analytics: analytics
        )
    }
    
    @Test func showsIntroductionBeforeFirstSignIn() async {
        #expect(await makeSUT().pendingRoute(at: .beforeSignIn) == .introduction)
    }
    
    @Test func completingIntroductionHidesItAndTracksIt() async {
        let sut = makeSUT()
        
        await sut.completeIntroduction()
        
        #expect(await sut.pendingRoute(at: .beforeSignIn) == nil)
        #expect(await analytics.events == [.introductionCompleted])
    }
    
    @Test func signingInCountsAsHavingSeenIntroduction() async {
        let sut = makeSUT(access: .authorized)
        
        _ = await sut.pendingRoute(at: .afterSignIn)
        
        #expect(await sut.pendingRoute(at: .beforeSignIn) == nil)
    }
    
    @Test func asksForNotificationsAfterSignIn() async {
        #expect(await makeSUT().pendingRoute(at: .afterSignIn) == .notificationPriming)
    }
    
    @Test func finishesOnceNotificationsAreDecided() async {
        let sut = makeSUT()
        
        preferences.markNotificationPrimingShown()
        
        #expect(await sut.pendingRoute(at: .afterSignIn) == nil)
    }
    
    @Test func offersProAfterNotificationsWhenEnabled() async {
        let sut = makeSUT()
        
        enablePaywall()
        preferences.markNotificationPrimingShown()
        
        #expect(await sut.pendingRoute(at: .afterSignIn) == .paywall)
    }
    
    @Test func asksForNotificationsBeforeOfferingPro() async {
        enablePaywall()
        
        #expect(await makeSUT().pendingRoute(at: .afterSignIn) == .notificationPriming)
    }
    
    @Test func offersProOnlyOnce() async {
        let sut = makeSUT()
        
        enablePaywall()
        preferences.markNotificationPrimingShown()
        preferences.markPaywallShown()
        
        #expect(await sut.pendingRoute(at: .afterSignIn) == nil)
    }
    
    @Test func skipsProOfferForSubscribers() async {
        let sut = makeSUT(entitlement: .pro)
        
        enablePaywall()
        preferences.markNotificationPrimingShown()
        
        #expect(await sut.pendingRoute(at: .afterSignIn) == nil)
    }
    
    private func enablePaywall() {
        defaults.set(true, forKey: PreferenceKey.paywallEnabled)
    }
}
