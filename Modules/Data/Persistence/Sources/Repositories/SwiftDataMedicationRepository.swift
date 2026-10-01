//
//  SwiftDataMedicationRepository.swift
//  Persistence
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Domain
internal import SwiftData
import Foundation

@ModelActor
actor SwiftDataMedicationRepository: MedicationCache {
    func fetchAll() async throws -> [Domain.Medication] {
        let descriptor = FetchDescriptor<MedicationEntity>(sortBy: [SortDescriptor(\.createdDate)])
        let data = try modelContext.fetch(descriptor)
        
        return try data.map { try MedicationMapper.toDomain($0) }
    }
    
    func fetch(id: UUID) async throws -> Domain.Medication {
        guard let data = try entity(id: id)
        else {
            throw DomainError.medicationNotFound
        }
        return try MedicationMapper.toDomain(data)
    }
    
    func save(_ medication: Domain.Medication) async throws {
        if let existingData = try entity(id: medication.id) {
            MedicationMapper.apply(
                medication,
                to: existingData
            )
        }
        else {
            modelContext.insert(
                MedicationMapper.toEntity(medication)
            )
        }
        try modelContext.save()
    }
    
    func delete(id: UUID) async throws {
        guard let data = try entity(id: id) else { return }
        modelContext.delete(data)
        try modelContext.save()
    }
    
    func replaceAll(with medications: [Domain.Medication]) async throws {
        var stale = Dictionary(
            try modelContext.fetch(FetchDescriptor<MedicationEntity>()).map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        
        for medication in medications {
            if let existing = stale.removeValue(forKey: medication.id) {
                MedicationMapper.apply(medication, to: existing)
                existing.createdDate = medication.createdDate
            }
            else {
                modelContext.insert(MedicationMapper.toEntity(medication))
            }
        }
        
        stale.values.forEach { modelContext.delete($0) }
        
        try modelContext.save()
    }
    
    private func entity(id: UUID) throws -> MedicationEntity? {
        var descriptor = FetchDescriptor<MedicationEntity>(predicate: #Predicate {$0.id == id })
        
        descriptor.fetchLimit = 1
        
        return try modelContext.fetch(descriptor).first
    }
}
