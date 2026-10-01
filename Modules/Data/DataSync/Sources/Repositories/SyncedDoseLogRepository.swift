//
//  SyncedDoseLogRepository.swift
//  DataSync
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import Foundation

/// Reads come from the cache, so they are instant and work offline. Every write goes to the cache and then to the server.
struct SyncedDoseLogRepository: DoseLogRepository {
    let cache: any DoseLogCache
    let remote: any DoseLogRemoteStore

    func fetch(from: Date, to: Date) async throws -> [DoseLog] {
        try await cache.fetch(from: from, to: to)
    }

    func save(_ log: DoseLog) async throws {
        try await cache.save(log)
        try await remote.save(log)
    }

    func delete(id: UUID) async throws {
        try await cache.delete(id: id)
        try await remote.delete(id: id)
    }

    func deleteAll(medicationId: UUID) async throws {
        try await cache.deleteAll(medicationId: medicationId)
        try await remote.deleteAll(medicationId: medicationId)
    }
}
