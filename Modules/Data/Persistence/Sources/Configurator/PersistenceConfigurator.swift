//
//  PersistenceConfigurator.swift
//  Persistence
//
//  Created by Sevar Jafarli on 26.09.26.
//

import DependencyInjection
import Domain

public enum PersistenceConfigurator {
    public static func setup(in container: DependencyContainer = .shared, inMemory: Bool = false) {
        let store = makeStore(inMemory: inMemory)

        container.register((any MedicationCache).self) { store.medications }
        container.register((any DoseLogCache).self) { store.doseLogs }
    }

    private static func makeStore(inMemory: Bool) -> PersistenceStore {
        do {
            return try PersistenceFactory.makeStore(inMemory: inMemory)
        }
        catch {
            return try! PersistenceFactory.makeStore(inMemory: true)
        }
    }
}
