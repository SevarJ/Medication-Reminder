//
//  SaveMedicationUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

public struct SaveMedicationUseCase: Sendable {
    private let repository: any MedicationRepository
    private let scheduler: any ReminderScheduling
    
    public init(
        repository: any MedicationRepository,
        scheduler: any ReminderScheduling
    ) {
        self.repository = repository
        self.scheduler = scheduler
    }
    
    public func execute(_ medication: Medication) async throws {
        guard !medication.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.nameEmpty
        }
        
        guard !medication.times.isEmpty else {
            throw DomainError.timeUnselected
        }
        
        guard Set(medication.times.map({ $0.hour * 60 + $0.minute })).count == medication.times.count else {
            throw DomainError.duplicateTime
        }
        
        try await repository.save(medication)
        
        if medication.isActive {
            try await scheduler.schedule(for: medication)
        }
        else {
            try await scheduler.cancel(for: medication.id)
        }
    }
}
