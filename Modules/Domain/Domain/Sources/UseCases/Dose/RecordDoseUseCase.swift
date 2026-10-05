//
//  RecordDoseUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

import Foundation

public struct RecordDoseUseCase: Sendable {
    private let doseLogRepository: any DoseLogRepository
    private let medicationRepository: any MedicationRepository
    private let calendar: Calendar
    
    public init(
        doseLogRepository: any DoseLogRepository,
        medicationRepository: any MedicationRepository,
        calendar: Calendar = .current
    ) {
        self.doseLogRepository = doseLogRepository
        self.medicationRepository = medicationRepository
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
        
        let newLog: DoseLog?
        
        if let log = dose.log {
            try await doseLogRepository.delete(id: log.id)
            
            newLog = log.status == status ? nil : makeLog(for: dose, status: status, now: now)
        }
        else {
            newLog = makeLog(for: dose, status: status, now: now)
        }
        
        if let newLog {
            try await doseLogRepository.save(newLog)
        }
        
        let medication = try await adjustStock(of: dose.medication, from: dose.log, to: newLog)
        
        return ScheduledDose(
            medication: medication,
            scheduledDate: dose.scheduledDate,
            log: newLog
        )
    }
    
    private func makeLog(for dose: ScheduledDose, status: DoseStatus, now: Date) -> DoseLog {
        DoseLog(
            medicationId: dose.medication.id,
            scheduledDate: dose.scheduledDate,
            status: status,
            recordedAt: now
        )
    }
    
    /// A taken dose uses up one dosage of the stock, and un-taking it puts the dosage back.
    private func adjustStock(of medication: Medication, from old: DoseLog?, to new: DoseLog?) async throws -> Medication {
        let wasTaken = old?.status == .taken
        let isTaken = new?.status == .taken
        
        guard medication.stock != nil, wasTaken != isTaken else { return medication }
        
        let current = try await medicationRepository.fetch(id: medication.id)
        
        guard let stock = current.stock else { return current }
        
        let change = isTaken ? -current.dosage.amount : current.dosage.amount
        let updated = current.updating(stock: max(0, stock + change))
        
        try await medicationRepository.save(updated)
        
        return updated
    }
}
