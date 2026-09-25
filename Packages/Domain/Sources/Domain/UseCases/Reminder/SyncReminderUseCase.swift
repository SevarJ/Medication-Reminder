//
//  SyncReminderUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 12.09.26.
//

public struct SyncReminderUseCase: Sendable {
    private let repository: any MedicationRepository
    private let scheduler: any ReminderScheduling
    
    public init(
        repository: any MedicationRepository,
        scheduler: any ReminderScheduling
    ) {
        self.repository = repository
        self.scheduler = scheduler
    }
    
    public func execute() async throws {
        
        let medications = try await repository.fetchAll()
        
        for medication in medications where medication.isActive {
            try await scheduler.schedule(for: medication)
        }
        
    }
}
