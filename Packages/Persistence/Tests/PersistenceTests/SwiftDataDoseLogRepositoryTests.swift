//
//  SwiftDataDoseLogRepositoryTests.swift
//  Persistence
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
import Testing
@testable import Persistence

struct SwiftDataDoseLogRepositoryTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func makeSUT() throws -> any DoseLogRepository {
        try PersistenceFactory.makeStore(inMemory: true).doseLogs
    }
    
    private func date(day: Int, hour: Int = 9, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeLog(
        medicationId: UUID = UUID(),
        scheduledDate: Date,
        status: DoseStatus = .taken
    ) -> DoseLog {
        DoseLog(
            medicationId: medicationId,
            scheduledDate: scheduledDate,
            status: status,
            recordedAt: scheduledDate
        )
    }
    
    @Test func savesAndFetchesLogWithinRange() async throws {
        let sut = try makeSUT()
        let log = makeLog(scheduledDate: try date(day: 16))
        
        try await sut.save(log)
        
        let stored = try await sut.fetch(from: try date(day: 16, hour: 0), to: try date(day: 17, hour: 0))
        
        #expect(stored == [log])
    }
    
    @Test func fetchExcludesLogsOutsideRange() async throws {
        let sut = try makeSUT()
        
        try await sut.save(makeLog(scheduledDate: try date(day: 15)))
        try await sut.save(makeLog(scheduledDate: try date(day: 17)))
        
        let stored = try await sut.fetch(from: try date(day: 16, hour: 0), to: try date(day: 17, hour: 0))
        
        #expect(stored.isEmpty)
    }
    
    @Test func fetchTreatsUpperBoundAsExclusive() async throws {
        let sut = try makeSUT()
        let boundary = try date(day: 17, hour: 0)
        
        try await sut.save(makeLog(scheduledDate: boundary))
        
        let stored = try await sut.fetch(from: try date(day: 16, hour: 0), to: boundary)
        
        #expect(stored.isEmpty)
    }
    
    @Test func savingSameLogTwiceUpdatesInPlace() async throws {
        let sut = try makeSUT()
        let log = makeLog(scheduledDate: try date(day: 16))
        
        try await sut.save(log)
        try await sut.save(
            DoseLog(
                id: log.id,
                medicationId: log.medicationId,
                scheduledDate: log.scheduledDate,
                status: .skipped,
                recordedAt: log.recordedAt
            )
        )
        
        let stored = try await sut.fetch(from: try date(day: 16, hour: 0), to: try date(day: 17, hour: 0))
        
        #expect(stored.count == 1)
        #expect(stored.first?.status == .skipped)
    }
    
    @Test func deleteRemovesSingleLog() async throws {
        let sut = try makeSUT()
        let log = makeLog(scheduledDate: try date(day: 16))
        
        try await sut.save(log)
        try await sut.delete(id: log.id)
        
        #expect(try await sut.fetch(from: try date(day: 16, hour: 0), to: try date(day: 17, hour: 0)).isEmpty)
    }
    
    @Test func deleteAllRemovesLogsOfGivenMedicationOnly() async throws {
        let sut = try makeSUT()
        let first = UUID()
        let second = UUID()
        
        try await sut.save(makeLog(medicationId: first, scheduledDate: try date(day: 16, hour: 9)))
        try await sut.save(makeLog(medicationId: first, scheduledDate: try date(day: 16, hour: 21)))
        try await sut.save(makeLog(medicationId: second, scheduledDate: try date(day: 16, hour: 12)))
        
        try await sut.deleteAll(medicationId: first)
        
        let stored = try await sut.fetch(from: try date(day: 16, hour: 0), to: try date(day: 17, hour: 0))
        
        #expect(stored.count == 1)
        #expect(stored.first?.medicationId == second)
    }
    
    @Test func mapperRejectsUnknownStatus() async throws {
        let entity = DoseLogEntity(
            id: UUID(),
            medicationId: UUID(),
            scheduledDate: .now,
            status: "postponed",
            recordedAt: .now
        )
        
        #expect(throws: PersistenceError.unknownDoseStatus("postponed")) {
            try DoseLogMapper.toDomain(entity)
        }
    }
}
