//
//  MockDoseLogRemoteStore.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import Foundation

public actor MockDoseLogRemoteStore: DoseLogRemoteStore {
    public private(set) var logs: [DoseLog]
    public private(set) var fetchedFrom: Date?
    public private(set) var fetchedTo: Date?
    public private(set) var fetchCount = 0
    public private(set) var deletedIds: [UUID] = []
    public private(set) var clearedMedicationIds: [UUID] = []

    private let fails: Bool

    public init(logs: [DoseLog] = [], fails: Bool = false) {
        self.logs = logs
        self.fails = fails
    }

    public func fetch(from date: Date, to end: Date?) async throws -> [DoseLog] {
        try failIfNeeded()

        fetchedFrom = date
        fetchedTo = end
        fetchCount += 1

        return logs.filter { log in
            log.scheduledDate >= date && (end.map { log.scheduledDate < $0 } ?? true)
        }
    }

    public func save(_ log: DoseLog) async throws {
        try failIfNeeded()

        logs.removeAll { $0.id == log.id }
        logs.append(log)
    }

    public func delete(id: UUID) async throws {
        try failIfNeeded()

        deletedIds.append(id)
        logs.removeAll { $0.id == id }
    }

    public func deleteAll(medicationId: UUID) async throws {
        try failIfNeeded()

        clearedMedicationIds.append(medicationId)
        logs.removeAll { $0.medicationId == medicationId }
    }

    private func failIfNeeded() throws {
        if fails {
            throw PersistenceFailure()
        }
    }
}
