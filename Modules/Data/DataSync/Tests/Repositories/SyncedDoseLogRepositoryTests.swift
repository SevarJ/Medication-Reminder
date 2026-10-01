//
//  SyncedDoseLogRepositoryTests.swift
//  DataSyncTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

@testable import DataSync
import Domain
import DomainTesting
import Foundation
import Testing

struct SyncedDoseLogRepositoryTests {
    private let scheduledDate = Date(timeIntervalSince1970: 1_790_000_000)

    private func makeLog(medicationId: UUID = UUID()) -> DoseLog {
        DoseLog(medicationId: medicationId, scheduledDate: scheduledDate, status: .taken, recordedAt: scheduledDate)
    }

    @Test func readsComeFromTheCacheOnly() async throws {
        let cached = makeLog()
        let sut = SyncedDoseLogRepository(
            cache: MockDoseLogRepository(logs: [cached]),
            remote: MockDoseLogRemoteStore(logs: [makeLog()], fails: true)
        )

        #expect(try await sut.fetch(from: scheduledDate, to: scheduledDate.addingTimeInterval(1)) == [cached])
    }

    @Test func savingWritesToCacheAndRemote() async throws {
        let cache = MockDoseLogRepository()
        let remote = MockDoseLogRemoteStore()
        let sut = SyncedDoseLogRepository(cache: cache, remote: remote)
        let log = makeLog()

        try await sut.save(log)

        #expect(await cache.logs == [log])
        #expect(await remote.logs == [log])
    }

    @Test func deletingRemovesFromCacheAndRemote() async throws {
        let log = makeLog()
        let cache = MockDoseLogRepository(logs: [log])
        let remote = MockDoseLogRemoteStore(logs: [log])
        let sut = SyncedDoseLogRepository(cache: cache, remote: remote)

        try await sut.delete(id: log.id)

        #expect(await cache.logs.isEmpty)
        #expect(await remote.deletedIds == [log.id])
    }

    @Test func deletingAMedicationsLogsClearsCacheAndRemote() async throws {
        let medicationId = UUID()
        let kept = makeLog()
        let cache = MockDoseLogRepository(logs: [makeLog(medicationId: medicationId), kept])
        let remote = MockDoseLogRemoteStore(logs: [makeLog(medicationId: medicationId), kept])
        let sut = SyncedDoseLogRepository(cache: cache, remote: remote)

        try await sut.deleteAll(medicationId: medicationId)

        #expect(await cache.logs == [kept])
        #expect(await remote.clearedMedicationIds == [medicationId])
        #expect(await remote.logs == [kept])
    }
}
