//
//  MockMedicationRemoteStore.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import Foundation

public actor MockMedicationRemoteStore: MedicationRemoteStore {
    public private(set) var medications: [Medication]
    public private(set) var savedMedications: [Medication] = []
    public private(set) var deletedIds: [UUID] = []

    private let fails: Bool

    public init(medications: [Medication] = [], fails: Bool = false) {
        self.medications = medications
        self.fails = fails
    }

    public func fetchAll() async throws -> [Medication] {
        try failIfNeeded()

        return medications
    }

    public func save(_ medication: Medication) async throws {
        try failIfNeeded()

        savedMedications.append(medication)
        medications.removeAll { $0.id == medication.id }
        medications.append(medication)
    }

    public func delete(id: UUID) async throws {
        try failIfNeeded()

        deletedIds.append(id)
        medications.removeAll { $0.id == id }
    }

    private func failIfNeeded() throws {
        if fails {
            throw PersistenceFailure()
        }
    }
}
