//
//  RecordDoseForMedicationUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public struct RecordDoseForMedicationUseCase: Sendable {
    private let loadDose: LoadScheduledDoseUseCase
    private let recordDose: RecordDoseUseCase
    
    public init(
        medicationRepository: any MedicationRepository,
        doseLogRepository: any DoseLogRepository,
        recordDose: RecordDoseUseCase
    ) {
        self.loadDose = LoadScheduledDoseUseCase(
            medicationRepository: medicationRepository,
            doseLogRepository: doseLogRepository
        )
        self.recordDose = recordDose
    }
    
    @discardableResult
    public func execute(
        medicationId: UUID,
        scheduledDate: Date,
        status: DoseStatus,
        now: Date = .now
    ) async throws -> ScheduledDose {
        let dose = try await loadDose.execute(medicationId: medicationId, scheduledDate: scheduledDate)
        
        return try await recordDose.execute(dose, status: status, now: now)
    }
}
