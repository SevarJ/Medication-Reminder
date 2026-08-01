//
//  PersistenceFactory.swift
//  Persistence
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Domain
import SwiftData

public enum PersistenceFactory {
    public static func makeRepository(inMemory: Bool = false) throws -> any MedicationRepository {
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        
        let container = try ModelContainer(
            for: MedicationEntity.self,
            configurations: config
        )
        
        return SwiftDataMedicationRepository(modelContainer: container)
    }
}
