//
//  SaveMedicationUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Testing
import Foundation
@testable import Domain

struct SaveMedicationUseCaseTests {
    private let repository = MockMedicationRepository()
    
    private let scheduler = MockReminderScheduler()
    
    private var sut: SaveMedicationUseCase {
        SaveMedicationUseCase(
            repository: repository,
            scheduler: scheduler
        )
    }
    
    @Test func medicationNameEmpty() async throws {
        await #expect(throws: DomainError.nameEmpty) {
           try await sut.execute(makeMedication(name: ""))
        }
        
        #expect(await repository.savedMedications.isEmpty)
    }
    
    @Test func medicationTimesEmpty() async throws {
        await #expect(throws: DomainError.timeUnselected) {
            try await sut.execute(makeMedication(times: []))
        }
        
        #expect(await repository.savedMedications.isEmpty)
    }
    
    @Test func medicationDuplicateTimes() async throws {
        await #expect(throws: DomainError.duplicateTime) {
            try await sut.execute(
                makeMedication(
                    times: [
                        (9, 0),
                        (9, 0)
                    ]
                )
            )
        }
        
        #expect(await repository.savedMedications.isEmpty)
    }
    
    @Test func medicationHourSameMinutesDifferent() async throws {
        let medication = try makeMedication(
            times: [
                (9, 0),
                (9, 30)
            ]
        )
        try await sut.execute(medication)
        
        #expect(await repository.savedMedications.count == 1)
        #expect(await scheduler.scheduledIds == [medication.id])
        #expect(await scheduler.cancelledIds.isEmpty)
    }
    
    @Test func medicationSaveActiveSchedule() async throws {
        let medication = try makeMedication()
        try await sut.execute(medication)
        
        #expect(await repository.savedMedications.count == 1)
        #expect(await scheduler.scheduledIds == [medication.id])
        #expect(await scheduler.cancelledIds.isEmpty)
    }
    
    @Test func medicationSaveInactiveSchedule() async throws {
        let medication = try makeMedication(isActive: false)
        try await sut.execute(medication)
        
        #expect(await repository.savedMedications.count == 1)
        #expect(await scheduler.scheduledIds.isEmpty)
        #expect(await scheduler.cancelledIds == [medication.id])
    }
}
