//
//  MockMedicationRepository.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

@testable import Domain
import Foundation

actor MockMedicationRepository: MedicationRepository {
    private(set) var savedMedications: [Medication] = []
    private(set) var deletedIds: [UUID] = []
    
    func fetchAll() async throws -> [Medication] {
        return []
    }
    
    func fetch(id: UUID) async throws -> Medication {
        throw DomainError.medicationNotFound
    }
    
    func save(_ medication: Medication) async throws {
        savedMedications.append(medication)
    }
    
    func delete(id: UUID) async throws {
        deletedIds.append(id)
    }
}
