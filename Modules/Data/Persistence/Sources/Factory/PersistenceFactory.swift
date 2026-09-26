//
//  PersistenceFactory.swift
//  Persistence
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Domain
internal import SwiftData

struct PersistenceStore: Sendable {
    let medications: any MedicationRepository
    let doseLogs: any DoseLogRepository
}

enum PersistenceFactory {
    static func makeStore(inMemory: Bool = false) throws -> PersistenceStore {
        let container = try ModelContainer(
            for: MedicationEntity.self, DoseLogEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
        )
        
        return PersistenceStore(
            medications: SwiftDataMedicationRepository(modelContainer: container),
            doseLogs: SwiftDataDoseLogRepository(modelContainer: container)
        )
    }
}
