//
//  SwiftDataDoseLogRepository.swift
//  Persistence
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
internal import SwiftData

@ModelActor
actor SwiftDataDoseLogRepository: DoseLogRepository {
    func fetch(from: Date, to: Date) async throws -> [DoseLog] {
        let descriptor = FetchDescriptor<DoseLogEntity>(
            predicate: #Predicate { $0.scheduledDate >= from && $0.scheduledDate < to },
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        
        return try modelContext.fetch(descriptor).map { try DoseLogMapper.toDomain($0) }
    }
    
    func save(_ log: DoseLog) async throws {
        if let existing = try entity(id: log.id) {
            DoseLogMapper.apply(log, to: existing)
        }
        else {
            modelContext.insert(DoseLogMapper.toEntity(log))
        }
        
        try modelContext.save()
    }
    
    func delete(id: UUID) async throws {
        guard let entity = try entity(id: id) else { return }
        
        modelContext.delete(entity)
        
        try modelContext.save()
    }
    
    func deleteAll(medicationId: UUID) async throws {
        try modelContext.delete(
            model: DoseLogEntity.self,
            where: #Predicate { $0.medicationId == medicationId }
        )
        
        try modelContext.save()
    }
    
    private func entity(id: UUID) throws -> DoseLogEntity? {
        var descriptor = FetchDescriptor<DoseLogEntity>(predicate: #Predicate { $0.id == id })
        
        descriptor.fetchLimit = 1
        
        return try modelContext.fetch(descriptor).first
    }
}
