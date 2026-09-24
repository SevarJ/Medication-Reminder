//
//  LoadScheduledDoseUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public struct LoadScheduledDoseUseCase: Sendable {
    private let medicationRepository: any MedicationRepository
    private let doseLogRepository: any DoseLogRepository
    
    public init(
        medicationRepository: any MedicationRepository,
        doseLogRepository: any DoseLogRepository
    ) {
        self.medicationRepository = medicationRepository
        self.doseLogRepository = doseLogRepository
    }
    
    public func execute(medicationId: UUID, scheduledDate: Date) async throws -> ScheduledDose {
        let medication = try await medicationRepository.fetch(id: medicationId)
        
        let existingLog = try await doseLogRepository
            .fetch(from: scheduledDate, to: scheduledDate.addingTimeInterval(1))
            .first { $0.medicationId == medicationId }
        
        return ScheduledDose(
            medication: medication,
            scheduledDate: scheduledDate,
            log: existingLog
        )
    }
}
