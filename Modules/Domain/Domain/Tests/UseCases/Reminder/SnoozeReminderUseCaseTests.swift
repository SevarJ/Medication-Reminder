//
//  SnoozeReminderUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct SnoozeReminderUseCaseTests {
    @Test func snoozesKnownMedication() async throws {
        let medication = try makeMedication()
        let scheduler = MockReminderScheduler()
        let analytics = MockAnalyticsTracker()
        let sut = SnoozeReminderUseCase(
            repository: MockMedicationRepository(medications: [medication]),
            scheduler: scheduler,
            analytics: analytics
        )
        
        let scheduledDate = Date(timeIntervalSince1970: 1_790_000_000)
        
        try await sut.execute(medicationId: medication.id, scheduledDate: scheduledDate)
        
        #expect(await scheduler.snoozedIds == [medication.id])
        #expect(await scheduler.snoozedDoseDates == [scheduledDate])
        #expect(await analytics.events == [.reminderSnoozed])
    }
    
    @Test func failsForUnknownMedication() async throws {
        let scheduler = MockReminderScheduler()
        let sut = SnoozeReminderUseCase(
            repository: MockMedicationRepository(),
            scheduler: scheduler,
            analytics: MockAnalyticsTracker()
        )
        
        await #expect(throws: DomainError.medicationNotFound) {
            try await sut.execute(medicationId: UUID(), scheduledDate: .now)
        }
        
        #expect(await scheduler.snoozedIds.isEmpty)
    }
}
