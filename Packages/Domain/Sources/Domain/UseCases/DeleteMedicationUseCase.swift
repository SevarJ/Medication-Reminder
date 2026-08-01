//
//  DeleteMedicationUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

public struct DeleteMedicationUseCase: Sendable {
    private let repository: any MedicationRepository
    private let scheduler: any ReminderScheduling
    
    public init(
        repository: any MedicationRepository,
        scheduler: any ReminderScheduling
    ) {
        self.repository = repository
        self.scheduler = scheduler
    }
    
    public func execute(id: UUID) async throws {
        try await scheduler.cancel(for: id)
        
        try await repository.delete(id: id)
    }
}
