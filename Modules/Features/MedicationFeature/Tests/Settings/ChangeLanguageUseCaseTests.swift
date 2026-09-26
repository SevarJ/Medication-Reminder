//
//  ChangeLanguageUseCaseTests.swift
//  MedicationFeatureTests
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import Domain
import DomainTesting
import Foundation
import Testing
@testable import MedicationFeature

struct ChangeLanguageUseCaseTests {
    private let store: UserDefaultsLanguageStore
    
    init() throws {
        let defaults = try #require(UserDefaults(suiteName: "ChangeLanguageUseCaseTests.\(UUID().uuidString)"))
        store = UserDefaultsLanguageStore(defaults: defaults)
    }
    
    private func makeSUT(
        scheduler: MockReminderScheduler,
        medications: [Medication]
    ) -> ChangeLanguageUseCase {
        ChangeLanguageUseCase(
            store: store,
            syncReminder: SyncReminderUseCase(
                repository: MockMedicationRepository(medications: medications),
                scheduler: scheduler
            )
        )
    }
    
    @Test func savesLanguageAndReschedulesReminders() async throws {
        let medication = try makeMedication()
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(scheduler: scheduler, medications: [medication])
        
        try await sut.execute(.russian)
        
        #expect(store.language == .russian)
        #expect(await scheduler.scheduledIds == [medication.id])
    }
    
    @Test func skipsReschedulingWhenLanguageIsUnchanged() async throws {
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(scheduler: scheduler, medications: [try makeMedication()])
        
        store.save(.azerbaijani)
        
        try await sut.execute(.azerbaijani)
        
        #expect(await scheduler.scheduledIds.isEmpty)
    }
}
