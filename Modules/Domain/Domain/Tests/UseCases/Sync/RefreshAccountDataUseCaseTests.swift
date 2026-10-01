//
//  RefreshAccountDataUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct RefreshAccountDataUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let now = Date(timeIntervalSince1970: 1_790_000_000)
    
    private func makeSUT(
        remoteMedications: MockMedicationRemoteStore = MockMedicationRemoteStore(),
        remoteDoseLogs: MockDoseLogRemoteStore = MockDoseLogRemoteStore(),
        medicationCache: MockMedicationRepository = MockMedicationRepository(),
        doseLogCache: MockDoseLogRepository = MockDoseLogRepository(),
        scheduler: MockReminderScheduler = MockReminderScheduler()
    ) -> RefreshAccountDataUseCase {
        RefreshAccountDataUseCase(
            remoteMedications: remoteMedications,
            remoteDoseLogs: remoteDoseLogs,
            medicationCache: medicationCache,
            doseLogCache: doseLogCache,
            scheduler: scheduler,
            calendar: calendar
        )
    }
    
    private func makeLog(daysAgo: Int) throws -> DoseLog {
        let date = try #require(calendar.date(byAdding: .day, value: -daysAgo, to: now))
        
        return DoseLog(medicationId: UUID(), scheduledDate: date, status: .taken, recordedAt: date)
    }
    
    @Test func replacesTheCacheWithWhatTheServerHolds() async throws {
        let remote = try makeMedication(name: "Remote")
        let medicationCache = MockMedicationRepository(medications: [try makeMedication(name: "Only on this device")])
        let remoteLog = try makeLog(daysAgo: 1)
        let doseLogCache = MockDoseLogRepository(logs: [try makeLog(daysAgo: 2)])
        let sut = makeSUT(
            remoteMedications: MockMedicationRemoteStore(medications: [remote]),
            remoteDoseLogs: MockDoseLogRemoteStore(logs: [remoteLog]),
            medicationCache: medicationCache,
            doseLogCache: doseLogCache
        )
        
        try await sut.execute(now: now)
        
        #expect(await medicationCache.medications == [remote])
        #expect(await doseLogCache.logs == [remoteLog])
    }
    
    @Test func asksOnlyForRecentDoseLogs() async throws {
        let recent = try makeLog(daysAgo: 3)
        let remoteDoseLogs = MockDoseLogRemoteStore(logs: [recent, try makeLog(daysAgo: 40)])
        let doseLogCache = MockDoseLogRepository()
        let sut = makeSUT(remoteDoseLogs: remoteDoseLogs, doseLogCache: doseLogCache)
        
        try await sut.execute(now: now)
        
        let firstDay = try #require(
            calendar.date(byAdding: .day, value: -RefreshAccountDataUseCase.doseLogDays, to: calendar.startOfDay(for: now))
        )
        
        #expect(await remoteDoseLogs.fetchedFrom == firstDay)
        #expect(await doseLogCache.logs == [recent])
    }
    
    @Test func schedulesRemindersForNewAndChangedMedications() async throws {
        let unchanged = try makeMedication(name: "Unchanged")
        let paused = try makeMedication(name: "Paused")
        let added = try makeMedication(name: "Added elsewhere")
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(
            remoteMedications: MockMedicationRemoteStore(medications: [unchanged, paused.updating(isActive: false), added]),
            medicationCache: MockMedicationRepository(medications: [unchanged, paused]),
            scheduler: scheduler
        )
        
        try await sut.execute(now: now)
        
        #expect(await scheduler.scheduledIds == [added.id])
        #expect(await scheduler.cancelledIds == [paused.id])
    }
    
    @Test func cancelsRemindersOfMedicationsDeletedElsewhere() async throws {
        let deleted = try makeMedication()
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(medicationCache: MockMedicationRepository(medications: [deleted]), scheduler: scheduler)
        
        try await sut.execute(now: now)
        
        #expect(await scheduler.cancelledIds == [deleted.id])
        #expect(await scheduler.scheduledIds.isEmpty)
    }
    
    @Test func leavesRemindersAloneWhenTheServerOnlyRoundedTheDates() async throws {
        let onDevice = try makeMedication(startDate: now, createdDate: now)
        let fromServer = Medication(
            id: onDevice.id,
            name: onDevice.name,
            dosage: onDevice.dosage,
            schedule: MedicationSchedule(
                times: onDevice.schedule.times,
                recurrence: onDevice.schedule.recurrence,
                startDate: now.addingTimeInterval(-0.000_4)
            ),
            isActive: true,
            createdDate: now.addingTimeInterval(-0.000_4)
        )
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(
            remoteMedications: MockMedicationRemoteStore(medications: [fromServer]),
            medicationCache: MockMedicationRepository(medications: [onDevice]),
            scheduler: scheduler
        )
        
        try await sut.execute(now: now)
        
        #expect(await scheduler.scheduledIds.isEmpty)
        #expect(await scheduler.cancelledIds.isEmpty)
    }
    
    @Test func refreshStillSucceedsWhileNotificationsAreOff() async throws {
        let medication = try makeMedication()
        let medicationCache = MockMedicationRepository()
        let sut = makeSUT(
            remoteMedications: MockMedicationRemoteStore(medications: [medication]),
            medicationCache: medicationCache,
            scheduler: MockReminderScheduler(failsWithAuthorizationDenied: true)
        )
        
        try await sut.execute(now: now)
        
        #expect(await medicationCache.medications == [medication])
    }
    
    @Test func failedFetchLeavesTheCacheUntouched() async throws {
        let cached = try makeMedication()
        let medicationCache = MockMedicationRepository(medications: [cached])
        let scheduler = MockReminderScheduler()
        let sut = makeSUT(
            remoteMedications: MockMedicationRemoteStore(fails: true),
            medicationCache: medicationCache,
            scheduler: scheduler
        )
        
        await #expect(throws: PersistenceFailure.self) {
            try await sut.execute(now: now)
        }
        
        #expect(await medicationCache.medications == [cached])
        #expect(await scheduler.cancelledIds.isEmpty)
    }
    
    @Test func cancelledRefreshLeavesTheCacheUntouched() async throws {
        let cached = try makeMedication(name: "Cached")
        let medicationCache = MockMedicationRepository(medications: [cached])
        let sut = makeSUT(
            remoteMedications: MockMedicationRemoteStore(medications: [try makeMedication(name: "Remote")]),
            medicationCache: medicationCache
        )
        let refresh = Task { [now] in
            try await sut.execute(now: now)
        }
        
        refresh.cancel()
        
        await #expect(throws: CancellationError.self) {
            try await refresh.value
        }
        
        #expect(await medicationCache.medications == [cached])
    }
}
