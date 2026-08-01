//
//  DeleteMedicationUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Testing
import Foundation
@testable import Domain

struct DeleteMedicationUseCaseTests {
    private let repository = MockMedicationRepository()
    
    private let scheduler = MockReminderScheduler()
    
    private var sut: DeleteMedicationUseCase {
        DeleteMedicationUseCase(
            repository: repository,
            scheduler: scheduler
        )
    }
    
    @Test func medicationDeleteSuccess() async throws {
        let medication = try makeMedication()
        
        try await sut.execute(id: medication.id)
        #expect(await repository.deletedIds == [medication.id])
        #expect(await scheduler.cancelledIds == [medication.id])
    }
}
