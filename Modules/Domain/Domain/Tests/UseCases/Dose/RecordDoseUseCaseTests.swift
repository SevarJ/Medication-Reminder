//
//  RecordDoseUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct RecordDoseUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int, minute: Int) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeSUT(repository: MockDoseLogRepository) -> RecordDoseUseCase {
        RecordDoseUseCase(
            doseLogRepository: repository,
            calendar: calendar
        )
    }
    
    private func makeDose(
        medication: Medication,
        scheduledDate: Date,
        status: DoseStatus? = nil
    ) -> ScheduledDose {
        ScheduledDose(
            medication: medication,
            scheduledDate: scheduledDate,
            log: status.map {
                DoseLog(
                    medicationId: medication.id,
                    scheduledDate: scheduledDate,
                    status: $0,
                    recordedAt: scheduledDate
                )
            }
        )
    }
    
    @Test func recordsTakenWhenNoLogExists() async throws {
        let now = try date(day: 17, hour: 14, minute: 30)
        let repository = MockDoseLogRepository()
        let dose = makeDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 17, hour: 9, minute: 0)
        )
        
        let result = try await makeSUT(repository: repository).execute(dose, status: .taken, now: now)
        
        let logs = await repository.logs
        
        #expect(logs.count == 1)
        #expect(logs.first?.status == .taken)
        #expect(logs.first?.recordedAt == now)
        #expect(result.state(at: now) == .taken)
    }
    
    @Test func removesLogWhenSameStatusTappedAgain() async throws {
        let now = try date(day: 17, hour: 14, minute: 30)
        let dose = makeDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 17, hour: 9, minute: 0),
            status: .taken
        )
        let repository = MockDoseLogRepository(logs: [try #require(dose.log)])
        
        let result = try await makeSUT(repository: repository).execute(dose, status: .taken, now: now)
        
        #expect(await repository.logs.isEmpty)
        #expect(result.log == nil)
    }
    
    @Test func replacesLogWhenStatusChanges() async throws {
        let now = try date(day: 17, hour: 14, minute: 30)
        let dose = makeDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 17, hour: 9, minute: 0),
            status: .taken
        )
        let repository = MockDoseLogRepository(logs: [try #require(dose.log)])
        
        let result = try await makeSUT(repository: repository).execute(dose, status: .skipped, now: now)
        
        let logs = await repository.logs
        
        #expect(logs.count == 1)
        #expect(logs.first?.status == .skipped)
        #expect(result.state(at: now) == .skipped)
    }
    
    @Test func rejectsDoseOlderThanEditableRange() async throws {
        let now = try date(day: 17, hour: 14, minute: 30)
        let repository = MockDoseLogRepository()
        let dose = makeDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 9, hour: 23, minute: 59)
        )
        
        await #expect(throws: DomainError.doseOutsideEditableRange) {
            try await makeSUT(repository: repository).execute(dose, status: .taken, now: now)
        }
        
        #expect(await repository.logs.isEmpty)
    }
    
    @Test func acceptsOldestDoseInEditableRange() async throws {
        let now = try date(day: 17, hour: 14, minute: 30)
        let repository = MockDoseLogRepository()
        let dose = makeDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 10, hour: 0, minute: 0)
        )
        
        _ = try await makeSUT(repository: repository).execute(dose, status: .taken, now: now)
        
        #expect(await repository.logs.count == 1)
    }
    
    @Test func allowsLaterDoseToday() async throws {
        let now = try date(day: 17, hour: 14, minute: 30)
        let repository = MockDoseLogRepository()
        let dose = makeDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 17, hour: 21, minute: 0)
        )
        
        _ = try await makeSUT(repository: repository).execute(dose, status: .taken, now: now)
        
        #expect(await repository.logs.count == 1)
    }
    
    @Test func rejectsDoseFromTomorrow() async throws {
        let now = try date(day: 17, hour: 14, minute: 30)
        let repository = MockDoseLogRepository()
        let dose = makeDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 18, hour: 0, minute: 0)
        )
        
        await #expect(throws: DomainError.doseOutsideEditableRange) {
            try await makeSUT(repository: repository).execute(dose, status: .taken, now: now)
        }
        
        #expect(await repository.logs.isEmpty)
    }
}
