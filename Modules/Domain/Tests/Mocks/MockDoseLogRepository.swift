//
//  MockDoseLogRepository.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

@testable import Domain
import Foundation

actor MockDoseLogRepository: DoseLogRepository {
    private(set) var logs: [DoseLog] = []
    
    init(logs: [DoseLog] = []) {
        self.logs = logs
    }
    func fetch(from: Date, to: Date) async throws -> [DoseLog] {
        return logs.filter {$0.scheduledDate >= from && $0.scheduledDate < to }
    }
    
    func save(_ log: DoseLog) async throws {
        logs.append(log)
    }
    
    func delete(id: UUID) async throws {
        logs.removeAll(where: {$0.id == id })
    }
    
    func deleteAll(medicationId: UUID) async throws {
        logs.removeAll(where: {$0.medicationId == medicationId })
    }
}
