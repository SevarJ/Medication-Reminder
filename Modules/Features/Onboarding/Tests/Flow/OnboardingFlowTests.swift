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
    private let preferences: AppPreferences
    
    init() throws {
        let suiteName = "OnboardingFlowTests.\(UUID().uuidString)"
        preferences = AppPreferences(defaults: try #require(UserDefaults(suiteName: suiteName)))
    }
    
    private func makeSUT(access: NotificationAccess = .notDetermined) -> OnboardingFlow {
        OnboardingFlow(
            preferences: preferences,
            priming: NotificationPrimingModel(
                authorizer: MockNotificationAuthorizer(access: access),
                syncReminder: SyncReminderUseCase(repository: MockMedicationRepository(), scheduler: MockReminderScheduler()),
                preferences: preferences
            )
        )
    }
    
    @Test func showsIntroductionBeforeFirstSignIn() async {
        #expect(await makeSUT().pendingRoute(at: .beforeSignIn) == .introduction)
    }
    
    @Test func skipsIntroductionOnceSeen() async {
        preferences.markIntroductionSeen()
        
        #expect(await makeSUT().pendingRoute(at: .beforeSignIn) == nil)
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
}
