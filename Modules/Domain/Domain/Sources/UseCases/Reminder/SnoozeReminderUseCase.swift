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
    
    public init(
        repository: any MedicationRepository,
        scheduler: any ReminderScheduling
    ) {
        self.repository = repository
        self.scheduler = scheduler
    }
    
    public func execute(
        medicationId: UUID,
        delay: TimeInterval = defaultDelay,
        now: Date = .now
    ) async throws {
        let medication = try await repository.fetch(id: medicationId)
        
        try await scheduler.snooze(medication, until: now.addingTimeInterval(delay))
    }
}
