//
//  RecordDoseUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

import Foundation

public struct RecordDoseUseCase: Sendable {
    private let doseLogRepository: any DoseLogRepository
    private let calendar: Calendar
    
    public init(
        doseLogRepository: any DoseLogRepository,
        calendar: Calendar = .current
    ) {
        self.doseLogRepository = doseLogRepository
        self.calendar = calendar
    }
    
    public func execute(
        _ dose: ScheduledDose,
        status: DoseStatus,
        now: Date = .now
    ) async throws -> ScheduledDose {
        let startOfToday = calendar.startOfDay(for: now)
        guard
            let earliest = calendar.date(byAdding: .day, value: -7, to: startOfToday),
            let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)
        else {
            throw DomainError.doseOutsideEditableRange
        }
        
        guard (earliest..<startOfTomorrow).contains(dose.scheduledDate) else {
            throw DomainError.doseOutsideEditableRange
        }
        
        if let log = dose.log {
            try await doseLogRepository.delete(id: log.id)
            if log.status == status {
                return ScheduledDose(
                    medication: dose.medication,
                    scheduledDate: dose.scheduledDate,
                    log: nil
                )
            }
        }
        
        let newLog: DoseLog = .init(
            medicationId: dose.medication.id,
            scheduledDate: dose.scheduledDate,
            status: status,
            recordedAt: now
        )
        
        try await doseLogRepository.save(newLog)
        
        return ScheduledDose(
            medication: dose.medication,
            scheduledDate: dose.scheduledDate,
            log: newLog
        )
    }
}

