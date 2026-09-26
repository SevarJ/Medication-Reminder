//
//  DeleteMedicationUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct DeleteMedicationUseCaseTests {
    private let repository = MockMedicationRepository()
    
    private let scheduler = MockReminderScheduler()
    
    private let logRepository = MockDoseLogRepository()
    
    private var sut: DeleteMedicationUseCase {
        DeleteMedicationUseCase(
            repository: repository,
            scheduler: scheduler,
            doseLogRepository: logRepository
        )
    }
    
    @Test func medicationDeleteSuccess() async throws {
        let medication = try makeMedication()
        
        try await sut.execute(id: medication.id)
        #expect(await repository.deletedIds == [medication.id])
        #expect(await scheduler.cancelledIds == [medication.id])
    }
    
    @Test func deletesLogsOfDeletedMedicationOnly() async throws {
        let first = try makeMedication(name: "Vitamin D")
        let second = try makeMedication(name: "Magnesium")
        
        let logRepository = MockDoseLogRepository(logs: [
            DoseLog(medicationId: first.id, scheduledDate: .now, status: .taken, recordedAt: .now),
            DoseLog(medicationId: first.id, scheduledDate: .now, status: .skipped, recordedAt: .now),
            DoseLog(medicationId: second.id, scheduledDate: .now, status: .taken, recordedAt: .now),
        ])
        
        let sut = DeleteMedicationUseCase(
            repository: repository,
            scheduler: scheduler,
            doseLogRepository: logRepository
        )
        
        try await sut.execute(id: first.id)
        
        let remaining = await logRepository.logs
        
        #expect(remaining.count == 1)
        #expect(remaining.first?.medicationId == second.id)
    }
}
