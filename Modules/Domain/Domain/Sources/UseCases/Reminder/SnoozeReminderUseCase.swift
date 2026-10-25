//
//  SnoozeReminderUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public struct SnoozeReminderUseCase: Sendable {
    public static let defaultDelay: TimeInterval = SnoozeDuration.default.interval
    
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
    
    public func execute(
        medicationId: UUID,
        scheduledDate: Date,
        delay: TimeInterval = defaultDelay,
        now: Date = .now
    ) async throws {
        let medication = try await repository.fetch(id: medicationId)
        
        try await scheduler.snooze(medication, scheduledDate: scheduledDate, until: now.addingTimeInterval(delay))
        await analytics.track(.reminderSnoozed)
    }
}
