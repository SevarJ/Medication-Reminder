//
//  NotificationPrimingModelTests.swift
//  OnboardingImplTests
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppPreferences
import Domain
import DomainTesting
import Foundation
import Testing
@testable import OnboardingImpl

@MainActor
struct NotificationPrimingModelTests {
    private let defaults: UserDefaults
    
    init() throws {
        let suiteName = "NotificationPrimingModelTests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suiteName))
    }
    
    private func makeSUT(
        authorizer: MockNotificationAuthorizer,
        scheduler: MockReminderScheduler = MockReminderScheduler(),
        medications: [Medication] = []
    ) -> NotificationPrimingModel {
        NotificationPrimingModel(
            authorizer: authorizer,
            syncReminder: SyncReminderUseCase(
                repository: MockMedicationRepository(medications: medications),
                scheduler: scheduler
            ),
            preferences: AppPreferences(defaults: defaults)
        )
    }
    
    @Test func presentsWhenPermissionWasNeverAsked() async throws {
        let sut = makeSUT(authorizer: MockNotificationAuthorizer(access: .notDetermined))
        
        #expect(await sut.shouldPresent())
    }
    
    @Test func staysHiddenOncePermissionIsDecided() async throws {
        for access in [NotificationAccess.authorized, .denied] {
            let sut = makeSUT(authorizer: MockNotificationAuthorizer(access: access))
            
            #expect(await sut.shouldPresent() == false)
        }
    }
    
    @Test func staysHiddenAfterUserDismissedIt() async throws {
        let authorizer = MockNotificationAuthorizer(access: .notDetermined)
        let first = makeSUT(authorizer: authorizer)
        
        first.dismiss()
        
        let second = makeSUT(authorizer: authorizer)
        
        #expect(await second.shouldPresent() == false)
        #expect(await authorizer.requestCount == 0)
    }
    
    @Test func allowingRequestsAccessAndSchedulesReminders() async throws {
        let medication = try makeMedication()
        let authorizer = MockNotificationAuthorizer(access: .notDetermined)
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(authorizer: authorizer, scheduler: scheduler, medications: [medication])
        
        await sut.allow()
        
        #expect(await sut.shouldPresent() == false)
        #expect(await authorizer.requestCount == 1)
        #expect(await scheduler.scheduledIds == [medication.id])
    }
    
    @Test func refusingSkipsReminderSync() async throws {
        let medication = try makeMedication()
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(
            authorizer: MockNotificationAuthorizer(access: .notDetermined, grantsOnRequest: false),
            scheduler: scheduler,
            medications: [medication]
        )
        
        await sut.allow()
        
        #expect(await sut.shouldPresent() == false)
        #expect(await scheduler.scheduledIds.isEmpty)
    }
}
