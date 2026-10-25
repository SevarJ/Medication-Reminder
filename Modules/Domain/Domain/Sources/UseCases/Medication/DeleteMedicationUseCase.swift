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
    private let doseLogRepository: any DoseLogRepository
    private let analytics: any AnalyticsTracking
    
    public init(
        repository: any MedicationRepository,
        scheduler: any ReminderScheduling,
        doseLogRepository: any DoseLogRepository,
        analytics: any AnalyticsTracking
    ) {
        self.repository = repository
        self.scheduler = scheduler
        self.doseLogRepository = doseLogRepository
        self.analytics = analytics
    }
    
    public func execute(id: UUID) async throws {
        try await scheduler.cancel(for: id)
        try await doseLogRepository.deleteAll(medicationId: id)
        try await repository.delete(id: id)
        await analytics.track(.medicationDeleted)
    }
}
