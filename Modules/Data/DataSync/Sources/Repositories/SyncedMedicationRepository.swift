//
//  SyncedMedicationRepository.swift
//  DataSync
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import Foundation

/// Reads come from the cache, so they are instant and work offline. Every write goes to the cache and then to the server.
struct SyncedMedicationRepository: MedicationRepository {
    let cache: any MedicationCache
    let remote: any MedicationRemoteStore

    func fetchAll() async throws -> [Medication] {
        try await cache.fetchAll()
    }

    func fetch(id: UUID) async throws -> Medication {
        try await cache.fetch(id: id)
    }

    func save(_ medication: Medication) async throws {
        try await cache.save(medication)
        try await remote.save(medication)
    }

    func delete(id: UUID) async throws {
        try await cache.delete(id: id)
        try await remote.delete(id: id)
    }
}
