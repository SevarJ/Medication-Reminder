//
//  SnoozeReminderUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

@testable import Domain
import Foundation
import Testing

struct SnoozeReminderUseCaseTests {
    @Test func snoozesKnownMedication() async throws {
        let medication = try makeMedication()
        let scheduler = MockReminderScheduler()
        let sut = SnoozeReminderUseCase(
            repository: MockMedicationRepository(medications: [medication]),
            scheduler: scheduler
        )
        
        try await sut.execute(medicationId: medication.id)
        
        #expect(await scheduler.snoozedIds == [medication.id])
    }
    
    @Test func failsForUnknownMedication() async throws {
        let scheduler = MockReminderScheduler()
        let sut = SnoozeReminderUseCase(
            repository: MockMedicationRepository(),
            scheduler: scheduler
        )
        
        await #expect(throws: DomainError.medicationNotFound) {
            try await sut.execute(medicationId: UUID())
        }
        
        #expect(await scheduler.snoozedIds.isEmpty)
    }
}
