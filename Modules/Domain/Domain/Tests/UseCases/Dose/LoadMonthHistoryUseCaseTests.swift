//
//  LoadMonthHistoryUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 05.10.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct LoadMonthHistoryUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    /// Mid-September, so the cached window starts on September 3.
    private var now: Date {
        get throws { try date(month: 9, day: 17, hour: 12) }
    }
    
    private func date(month: Int, day: Int, hour: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))
        )
    }
    
    private func makeLog(
        for medication: Medication,
        month: Int,
        day: Int,
        status: DoseStatus = .taken
    ) throws -> DoseLog {
        let scheduled = try date(month: month, day: day, hour: 9)
        
        return DoseLog(medicationId: medication.id, scheduledDate: scheduled, status: status, recordedAt: scheduled)
    }
    
    private func makeSUT(
        medications: [Medication],
        cachedLogs: [DoseLog] = [],
        remote: MockDoseLogRemoteStore = MockDoseLogRemoteStore()
    ) -> LoadMonthHistoryUseCase {
        LoadMonthHistoryUseCase(
            medicationRepository: MockMedicationRepository(medications: medications),
            doseLogRepository: MockDoseLogRepository(logs: cachedLogs),
            remoteDoseLogs: remote,
            calendar: calendar
        )
    }
    
    @Test func readsAnOlderMonthFromTheServer() async throws {
        let medication = try makeMedication(startDate: try date(month: 8, day: 1))
        let remote = MockDoseLogRemoteStore(logs: [try makeLog(for: medication, month: 8, day: 10)])
        let sut = makeSUT(medications: [medication], remote: remote)
        
        let august = try await sut.execute(month: try date(month: 8, day: 15), now: try now)
        
        #expect(august.count == 31)
        #expect(august.map { $0.takenCount }.reduce(0, +) == 1)
        #expect(await remote.fetchedFrom == (try date(month: 8, day: 1)))
        #expect(await remote.fetchedTo == (try date(month: 9, day: 1)))
    }
    
    @Test func readsTheCurrentMonthFromBothSides() async throws {
        let medication = try makeMedication(startDate: try date(month: 8, day: 1))
        let remote = MockDoseLogRemoteStore(logs: [try makeLog(for: medication, month: 9, day: 1)])
        let cached = [try makeLog(for: medication, month: 9, day: 10)]
        let sut = makeSUT(medications: [medication], cachedLogs: cached, remote: remote)
        
        let september = try await sut.execute(month: try date(month: 9, day: 17), now: try now)
        
        #expect(september.map { $0.takenCount }.reduce(0, +) == 2)
        #expect(await remote.fetchedFrom == (try date(month: 9, day: 1)))
        #expect(await remote.fetchedTo == (try date(month: 9, day: 3)))
    }
    
    @Test func ignoresServerLogsInsideTheCachedWindow() async throws {
        let medication = try makeMedication(startDate: try date(month: 8, day: 1))
        let remote = MockDoseLogRemoteStore(logs: [try makeLog(for: medication, month: 9, day: 10)])
        let sut = makeSUT(medications: [medication], remote: remote)
        
        let september = try await sut.execute(month: try date(month: 9, day: 17), now: try now)
        
        #expect(september.map { $0.takenCount }.reduce(0, +) == 0)
    }
    
    @Test func stopsAtToday() async throws {
        let medication = try makeMedication(startDate: try date(month: 8, day: 1))
        let sut = makeSUT(medications: [medication])
        
        let september = try await sut.execute(month: try date(month: 9, day: 1), now: try now)
        
        #expect(september.count == 17)
        #expect(september.last?.date == (try date(month: 9, day: 17)))
    }
    
    @Test func keepsARecentMonthOffTheServer() async throws {
        let medication = try makeMedication(startDate: try date(month: 8, day: 1))
        let remote = MockDoseLogRemoteStore(fails: true)
        let sut = makeSUT(
            medications: [medication],
            cachedLogs: [try makeLog(for: medication, month: 10, day: 1)],
            remote: remote
        )
        
        let october = try await sut.execute(month: try date(month: 10, day: 5), now: try date(month: 10, day: 10, hour: 12))
        
        #expect(october.count == 10)
        #expect(october.first?.takenCount == 1)
        #expect(await remote.fetchCount == 0)
    }
    
    @Test func failsWhenTheServerCannotBeReached() async throws {
        let medication = try makeMedication(startDate: try date(month: 8, day: 1))
        let sut = makeSUT(medications: [medication], remote: MockDoseLogRemoteStore(fails: true))
        
        await #expect(throws: (any Error).self) {
            try await sut.execute(month: try date(month: 8, day: 15), now: try now)
        }
    }
    
    @Test func listsDaysOldestFirstAndSkipsDaysWithoutDoses() async throws {
        let medication = try makeMedication(
            recurrence: .daysOfWeek([.wednesday]),
            startDate: try date(month: 8, day: 1)
        )
        let sut = makeSUT(medications: [medication])
        
        let august = try await sut.execute(month: try date(month: 8, day: 15), now: try now)
        
        #expect(august.map { calendar.component(.day, from: $0.date) } == [5, 12, 19, 26])
    }
    
    @Test func startsAtTheMedicationStartDate() async throws {
        let medication = try makeMedication(startDate: try date(month: 8, day: 20))
        let sut = makeSUT(medications: [medication])
        
        let august = try await sut.execute(month: try date(month: 8, day: 1), now: try now)
        
        #expect(august.count == 12)
        #expect(august.first?.date == (try date(month: 8, day: 20)))
    }
    
    @Test func excludesInactiveMedications() async throws {
        let medication = try makeMedication(startDate: try date(month: 8, day: 1), isActive: false)
        let sut = makeSUT(medications: [medication])
        
        #expect(try await sut.execute(month: try date(month: 8, day: 15), now: try now).isEmpty)
    }
    
    @Test func findsTheMonthOfTheEarliestMedication() async throws {
        let sut = LoadMonthHistoryUseCase(
            medicationRepository: MockMedicationRepository(medications: [
                try makeMedication(startDate: try date(month: 8, day: 20)),
                try makeMedication(startDate: try date(month: 6, day: 3)),
                try makeMedication(startDate: try date(month: 2, day: 1), isActive: false)
            ]),
            doseLogRepository: MockDoseLogRepository(),
            remoteDoseLogs: MockDoseLogRemoteStore(),
            calendar: calendar
        )
        
        #expect(try await sut.earliestMonth() == (try date(month: 6, day: 1)))
    }
    
    @Test func hasNoEarliestMonthWithoutMedications() async throws {
        let sut = makeSUT(medications: [])
        
        #expect(try await sut.earliestMonth() == nil)
    }
}
