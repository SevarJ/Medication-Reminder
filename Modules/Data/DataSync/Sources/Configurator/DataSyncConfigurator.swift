//
//  DataSyncConfigurator.swift
//  DataSync
//
//  Created by Sevar Jafarli on 01.10.26.
//

import DependencyInjection
import Domain

public enum DataSyncConfigurator {
    /// The caches and remote stores are resolved on first use, so the modules that register them can be set up in any order.
    public static func setup(in container: DependencyContainer = .shared) {
        container.register((any MedicationRepository).self) {
            SyncedMedicationRepository(cache: container.resolve(), remote: container.resolve())
        }
        container.register((any DoseLogRepository).self) {
            SyncedDoseLogRepository(cache: container.resolve(), remote: container.resolve())
        }
    }
}
