//
//  PersistenceConfiguratorTests.swift
//  PersistenceTests
//
//  Created by Sevar Jafarli on 26.09.26.
//

import DependencyInjection
import Domain
@testable import Persistence
import Testing

struct PersistenceConfiguratorTests {
    @Test func registersBothRepositories() async throws {
        let container = DependencyContainer()

        PersistenceConfigurator.setup(in: container, inMemory: true)

        #expect(try await container.resolve((any MedicationRepository).self).fetchAll().isEmpty)
        #expect(container.isRegistered((any DoseLogRepository).self))
    }
}
