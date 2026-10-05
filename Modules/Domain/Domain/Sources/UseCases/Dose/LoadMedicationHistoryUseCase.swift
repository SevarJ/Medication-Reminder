//
//  LoadMedicationHistoryUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 05.10.26.
//

import Foundation

/// The dose history of one medication, whether or not it is currently paused. Every day of the range is returned, newest first, even when nothing was scheduled.
public struct LoadMedicationHistoryUseCase: Sendable {
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
        _ medication: Medication,
        endingOn date: Date,
        days: Int = LoadDoseHistoryUseCase.defaultDayCount
    ) async throws -> [DoseDaySummary] {
        let lastDay = calendar.startOfDay(for: date)
        
        guard days > 0,
              let firstDay = calendar.date(byAdding: .day, value: -(days - 1), to: lastDay),
              let endOfRange = calendar.date(byAdding: .day, value: 1, to: lastDay)
        else {
            return []
        }
        
        let logs = try await doseLogRepository.fetch(from: firstDay, to: endOfRange)
        
        return stride(from: 0, to: days, by: 1)
            .compactMap { calendar.date(byAdding: .day, value: -$0, to: lastDay) }
            .map { day in
                DoseDaySummary(
                    date: day,
                    doses: DoseAssembler.doses(for: [medication], on: day, logs: logs, calendar: calendar)
                )
            }
    }
}
