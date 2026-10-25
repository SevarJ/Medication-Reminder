//
//  SaveMedicationUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

public struct SaveMedicationUseCase: Sendable {
    private let repository: any MedicationRepository
    private let scheduler: any ReminderScheduling
    private let analytics: any AnalyticsTracking
    
    public init(
        repository: any MedicationRepository,
        scheduler: any ReminderScheduling,
        analytics: any AnalyticsTracking
    ) {
        self.repository = repository
        self.scheduler = scheduler
        self.analytics = analytics
    }
    
    public func execute(_ medication: Medication) async throws {
        guard !medication.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.nameEmpty
        }
        
        let schedule = medication.schedule
        
        guard !schedule.times.isEmpty else {
            throw DomainError.timeUnselected
        }
        
        guard Set(schedule.times.map({ $0.hour * 60 + $0.minute })).count == schedule.times.count else {
            throw DomainError.duplicateTime
        }
        
        guard !schedule.recurrence.weekdays.isEmpty else {
            throw DomainError.weekdayUnselected
        }
        
        if let endDate = schedule.endDate, endDate < schedule.startDate {
            throw DomainError.invalidDateRange
        }
        
        let isNew = (try? await repository.fetch(id: medication.id)) == nil
        
        try await repository.save(medication)
        
        if isNew {
            await analytics.track(.medicationAdded)
        }
        
        if medication.isActive {
            try await scheduler.schedule(for: medication)
        }
        else {
            try await scheduler.cancel(for: medication.id)
        }
    }
}
