//
//  LoadDoseHistoryUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public struct LoadDoseHistoryUseCase: Sendable {
    public static let defaultDayCount = 7
    
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
    
    public func execute(
        endingOn date: Date,
        days: Int = defaultDayCount
    ) async throws -> [DoseDaySummary] {
        let lastDay = calendar.startOfDay(for: date)
        
        guard days > 0,
              let firstDay = calendar.date(byAdding: .day, value: -(days - 1), to: lastDay),
              let endOfRange = calendar.date(byAdding: .day, value: 1, to: lastDay)
        else {
            return []
        }
        
        let medications = try await medicationRepository
            .fetchAll()
            .filter { $0.isActive }
        let logs = try await doseLogRepository.fetch(from: firstDay, to: endOfRange)
        
        return stride(from: 0, to: days, by: 1)
            .compactMap { calendar.date(byAdding: .day, value: -$0, to: lastDay) }
            .map { day in
                DoseDaySummary(
                    date: day,
                    doses: DoseAssembler.doses(
                        for: medications,
                        on: day,
                        logs: logs,
                        calendar: calendar
                    )
                )
            }
            .filter { !$0.doses.isEmpty }
    }
}
