//
//  RecordDoseForMedicationUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public struct RecordDoseForMedicationUseCase: Sendable {
    private let medicationRepository: any MedicationRepository
    private let doseLogRepository: any DoseLogRepository
    private let recordDose: RecordDoseUseCase
    
    public init(
        medicationRepository: any MedicationRepository,
        doseLogRepository: any DoseLogRepository,
        recordDose: RecordDoseUseCase
    ) {
        self.medicationRepository = medicationRepository
        self.doseLogRepository = doseLogRepository
        self.recordDose = recordDose
    }
    
    @discardableResult
    public func execute(
        medicationId: UUID,
        scheduledDate: Date,
        status: DoseStatus,
        now: Date = .now
    ) async throws -> ScheduledDose {
        let medication = try await medicationRepository.fetch(id: medicationId)
        
        let existingLog = try await doseLogRepository
            .fetch(from: scheduledDate, to: scheduledDate.addingTimeInterval(1))
            .first { $0.medicationId == medicationId }
        
        let dose = ScheduledDose(
            medication: medication,
            scheduledDate: scheduledDate,
            log: existingLog
        )
        
        return try await recordDose.execute(dose, status: status, now: now)
    }
}
