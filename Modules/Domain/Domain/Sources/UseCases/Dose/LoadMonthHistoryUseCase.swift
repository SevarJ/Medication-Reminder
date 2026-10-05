//
//  LoadMonthHistoryUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 05.10.26.
//

import Foundation

/// The dose history of one calendar month. Days inside the cached window come from the device, so they include writes
/// that have not reached the server yet. Older days come from the server, which needs a connection.
public struct LoadMonthHistoryUseCase: Sendable {
    private let medicationRepository: any MedicationRepository
    private let doseLogRepository: any DoseLogRepository
    private let remoteDoseLogs: any DoseLogRemoteStore
    private let calendar: Calendar
    
    public init(
        medicationRepository: any MedicationRepository,
        doseLogRepository: any DoseLogRepository,
        remoteDoseLogs: any DoseLogRemoteStore,
        calendar: Calendar = .current
    ) {
        self.medicationRepository = medicationRepository
        self.doseLogRepository = doseLogRepository
        self.remoteDoseLogs = remoteDoseLogs
        self.calendar = calendar
    }
    
    /// The first month any medication was scheduled in, or `nil` without medications. There is nothing to show before it.
    public func earliestMonth() async throws -> Date? {
        let first = try await medicationRepository
            .fetchAll()
            .filter { $0.isActive }
            .map { $0.schedule.startDate }
            .min()
        
        return first.flatMap { calendar.dateInterval(of: .month, for: $0)?.start }
    }
    
    /// The days of the month up to today that have doses scheduled, oldest first.
    public func execute(
        month: Date,
        now: Date = .now
    ) async throws -> [DoseDaySummary] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else {
            return []
        }
        
        let today = calendar.startOfDay(for: now)
        let cacheStart = calendar.date(byAdding: .day, value: -RefreshAccountDataUseCase.doseLogDays, to: today) ?? today
        
        let medications = try await medicationRepository
            .fetchAll()
            .filter { $0.isActive }
        let logs = try await logs(from: interval.start, to: interval.end, cacheStart: cacheStart)
        
        return stride(from: 0, to: dayCount(of: interval), by: 1)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
            .filter { $0 <= today }
            .map { day in
                DoseDaySummary(
                    date: day,
                    doses: DoseAssembler.doses(for: medications, on: day, logs: logs, calendar: calendar)
                )
            }
            .filter { !$0.doses.isEmpty }
    }
    
    private func logs(from start: Date, to end: Date, cacheStart: Date) async throws -> [DoseLog] {
        var logs: [DoseLog] = []
        
        if start < cacheStart {
            logs += try await remoteDoseLogs.fetch(from: start, to: min(end, cacheStart))
        }
        
        if end > cacheStart {
            logs += try await doseLogRepository.fetch(from: max(start, cacheStart), to: end)
        }
        
        return logs
    }
    
    private func dayCount(of interval: DateInterval) -> Int {
        calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 0
    }
}
