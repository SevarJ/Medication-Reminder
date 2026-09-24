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
        
        return DoseAssembler.doses(
            for: medications,
            on: date,
            logs: logs,
            calendar: calendar
        )
    }
}
