//
//  LoadDosesUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

import Foundation

public struct LoadDosesUseCase: Sendable {
    private let medicationRepository: any MedicationRepository
    private let doseLogRepository: any DoseLogRepository
    private let calendar: Calendar
    
    public init(
        medicationRepository: any MedicationRepository,
        doseLogRepository: any DoseLogRepository,
        calendar: Calendar = .current
    ) {
        self.medicationRepository = medicationRepository
        self.doseLogRepository = doseLogRepository
        self.calendar = calendar
    }
    
    public func execute(on date: Date) async throws -> [ScheduledDose] {
        let medications = try await medicationRepository
            .fetchAll()
            .filter { $0.isActive }
        
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        let logs = try await doseLogRepository.fetch(from: startOfDay, to: startOfNextDay)
        
        let logsByDose = Dictionary(
            logs.map { log in
                (ScheduledDose.ID(medicationId: log.medicationId, scheduledDate: log.scheduledDate), log)
            },
            uniquingKeysWith: { _, latest in latest }
        )
        
        return medications
            .flatMap { medication in
                medication.schedule
                    .doses(on: date, calendar: calendar)
                    .map { scheduledDate in
                        let id = ScheduledDose.ID(medicationId: medication.id, scheduledDate: scheduledDate)
                        
                        return ScheduledDose(
                            medication: medication,
                            scheduledDate: scheduledDate,
                            log: logsByDose[id]
                        )
                    }
            }
            .sorted { ($0.scheduledDate, $0.medication.name) < ($1.scheduledDate, $1.medication.name) }
    }
}
