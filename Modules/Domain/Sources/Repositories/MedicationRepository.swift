//
//  MedicationRepository.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

public protocol MedicationRepository: Sendable {
    func fetchAll() async throws -> [Medication]
    func fetch(id: UUID) async throws -> Medication
    func save(_ medication: Medication) async throws
    func delete(id: UUID) async throws
}
