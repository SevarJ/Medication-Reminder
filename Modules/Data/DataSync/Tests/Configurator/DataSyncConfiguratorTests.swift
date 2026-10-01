//
//  DataSyncConfiguratorTests.swift
//  DataSyncTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

@testable import DataSync
import DependencyInjection
import Domain
import DomainTesting
import Testing

struct DataSyncConfiguratorTests {
    @Test func registersRepositoriesBackedByCacheAndRemote() async throws {
        let container = DependencyContainer()
        let medication = try makeMedication()
        let cache = MockMedicationRepository()
        let remote = MockMedicationRemoteStore()

        container.register((any MedicationCache).self) { cache }
        container.register((any MedicationRemoteStore).self) { remote }
        container.register((any DoseLogCache).self) { MockDoseLogRepository() }
        container.register((any DoseLogRemoteStore).self) { MockDoseLogRemoteStore() }

        DataSyncConfigurator.setup(in: container)

        try await container.resolve((any MedicationRepository).self).save(medication)

        #expect(await cache.medications == [medication])
        #expect(await remote.medications == [medication])
        #expect(container.isRegistered((any DoseLogRepository).self))
    }
}
