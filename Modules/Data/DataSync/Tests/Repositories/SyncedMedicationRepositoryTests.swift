//
//  SyncedMedicationRepositoryTests.swift
//  DataSyncTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

@testable import DataSync
import Domain
import DomainTesting
import Testing

struct SyncedMedicationRepositoryTests {
    @Test func readsComeFromTheCacheOnly() async throws {
        let cached = try makeMedication(name: "Cached")
        let sut = SyncedMedicationRepository(
            cache: MockMedicationRepository(medications: [cached]),
            remote: MockMedicationRemoteStore(medications: [try makeMedication(name: "Remote")], fails: true)
        )

        #expect(try await sut.fetchAll() == [cached])
        #expect(try await sut.fetch(id: cached.id) == cached)
    }

    @Test func savingWritesToCacheAndRemote() async throws {
        let cache = MockMedicationRepository()
        let remote = MockMedicationRemoteStore()
        let sut = SyncedMedicationRepository(cache: cache, remote: remote)
        let medication = try makeMedication()

        try await sut.save(medication)

        #expect(await cache.medications == [medication])
        #expect(await remote.savedMedications == [medication])
    }

    @Test func deletingRemovesFromCacheAndRemote() async throws {
        let medication = try makeMedication()
        let cache = MockMedicationRepository(medications: [medication])
        let remote = MockMedicationRemoteStore(medications: [medication])
        let sut = SyncedMedicationRepository(cache: cache, remote: remote)

        try await sut.delete(id: medication.id)

        #expect(await cache.medications.isEmpty)
        #expect(await remote.deletedIds == [medication.id])
    }

    @Test func remoteFailureIsReported() async throws {
        let sut = SyncedMedicationRepository(cache: MockMedicationRepository(), remote: MockMedicationRemoteStore(fails: true))

        await #expect(throws: PersistenceFailure.self) {
            try await sut.save(try makeMedication())
        }
    }
}
