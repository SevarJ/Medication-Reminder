//
//  MockMedicationRepository.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Domain
import Foundation

public actor MockMedicationRepository: MedicationRepository {
    public private(set) var medications: [Medication]
    public private(set) var savedMedications: [Medication] = []
    public private(set) var deletedIds: [UUID] = []

    private let fetchAllFails: Bool
    private var fetchAllHook: (@Sendable () async -> Void)?

    public init(medications: [Medication] = [], fetchAllFails: Bool = false) {
        self.medications = medications
        self.fetchAllFails = fetchAllFails
    }

    public func setFetchAllHook(_ hook: @escaping @Sendable () async -> Void) {
        fetchAllHook = hook
    }

    public func fetchAll() async throws -> [Medication] {
        await fetchAllHook?()

        if fetchAllFails {
            throw PersistenceFailure()
        }

        return medications
    }

    public func fetch(id: UUID) async throws -> Medication {
        guard let medication = medications.first(where: { $0.id == id }) else {
            throw DomainError.medicationNotFound
        }

        return medication
    }

    public func save(_ medication: Medication) async throws {
        savedMedications.append(medication)
        medications.removeAll { $0.id == medication.id }
        medications.append(medication)
    }

    public func delete(id: UUID) async throws {
        deletedIds.append(id)
        medications.removeAll { $0.id == id }
    }
}
