//
//  MockDoseLogRepository.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Domain
import Foundation

public actor MockDoseLogRepository: DoseLogRepository {
    public private(set) var logs: [DoseLog]

    public init(logs: [DoseLog] = []) {
        self.logs = logs
    }

    public func fetch(from: Date, to: Date) async throws -> [DoseLog] {
        logs.filter { $0.scheduledDate >= from && $0.scheduledDate < to }
    }

    public func save(_ log: DoseLog) async throws {
        logs.removeAll { $0.id == log.id }
        logs.append(log)
    }

    public func delete(id: UUID) async throws {
        logs.removeAll { $0.id == id }
    }

    public func deleteAll(medicationId: UUID) async throws {
        logs.removeAll { $0.medicationId == medicationId }
    }
}
