//
//  ToggleMedicationActiveUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Testing
import Foundation
@testable import Domain

struct ToggleMedicationActiveUseCaseTests {
    private let repository = MockMedicationRepository()
    
    private let scheduler = MockReminderScheduler()
    
    private var sut: ToggleMedicationActiveUseCase {
        ToggleMedicationActiveUseCase(
            saveMedication: SaveMedicationUseCase(
                repository: repository,
                scheduler: scheduler
            )
        )
    }
    
    @Test func medicationMakeActive() async throws {
        let medication = try makeMedication(isActive: false)
        
        let updated = try await sut.execute(medication)
        
        #expect(updated.isActive == true)
        #expect(updated.id == medication.id)
        #expect(await repository.savedMedications.count == 1)
        #expect(await scheduler.scheduledIds == [medication.id])
        #expect(await scheduler.cancelledIds.isEmpty)
    }
    
    @Test func medicationMakeInactive() async throws {
        let medication = try makeMedication()

        let updated = try await sut.execute(medication)
        
        #expect(updated.isActive == false)
        #expect(updated.id == medication.id)
        #expect(await repository.savedMedications.count == 1)
        #expect(await scheduler.cancelledIds == [medication.id])
        #expect(await scheduler.scheduledIds.isEmpty)
    }
}
