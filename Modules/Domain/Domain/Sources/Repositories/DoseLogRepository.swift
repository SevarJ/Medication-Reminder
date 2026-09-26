//
//  DoseLogRepository.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

import Foundation

public protocol DoseLogRepository: Sendable {
    func fetch(from: Date, to: Date) async throws -> [DoseLog]
    func save(_ log: DoseLog) async throws
    func delete(id: UUID) async throws
    func deleteAll(medicationId: UUID) async throws
}
