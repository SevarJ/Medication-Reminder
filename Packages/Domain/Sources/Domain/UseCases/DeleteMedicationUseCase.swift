//
//  DeleteMedicationUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

public struct DeleteMedicationUseCase: Sendable {
    private let repository: any MedicationRepository
    private let scheduler: any ReminderScheduling
    private let doseLogRepository: any DoseLogRepository
    
    public init(
        repository: any MedicationRepository,
        scheduler: any ReminderScheduling,
        doseLogRepository: any DoseLogRepository
    ) {
        self.repository = repository
        self.scheduler = scheduler
        self.doseLogRepository = doseLogRepository
    }
    
    public func execute(id: UUID) async throws {
        try await scheduler.cancel(for: id)
        try await doseLogRepository.deleteAll(medicationId: id)
        try await repository.delete(id: id)
    }
}
