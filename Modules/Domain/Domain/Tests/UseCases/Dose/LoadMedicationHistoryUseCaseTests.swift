//
//  LoadMedicationHistoryUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 05.10.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct LoadMedicationHistoryUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int = 0, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeSUT(logs: [DoseLog] = []) -> LoadMedicationHistoryUseCase {
        LoadMedicationHistoryUseCase(
            doseLogRepository: MockDoseLogRepository(logs: logs),
            calendar: calendar
        )
    }
    
    @Test func returnsDaysNewestFirst() async throws {
        let medication = try makeMedication(startDate: try date(day: 1))
        
        let history = try await makeSUT().execute(medication, endingOn: try date(day: 17, hour: 12), days: 3)
        
        #expect(history.map { $0.date } == [try date(day: 17), try date(day: 16), try date(day: 15)])
    }
    
    @Test func includesPausedMedication() async throws {
        let medication = try makeMedication(startDate: try date(day: 1), isActive: false)
        
        let history = try await makeSUT().execute(medication, endingOn: try date(day: 17, hour: 12), days: 1)
        
        #expect(history.count == 1)
    }
    
    @Test func keepsDaysBeforeTheMedicationStartedWithoutDoses() async throws {
        let medication = try makeMedication(startDate: try date(day: 16))
        
        let history = try await makeSUT().execute(medication, endingOn: try date(day: 17, hour: 12), days: 7)
        
        #expect(history.count == 7)
        #expect(history.filter { !$0.doses.isEmpty }.map { $0.date } == [try date(day: 17), try date(day: 16)])
    }
    
    @Test func ignoresLogsOfOtherMedications() async throws {
        let medication = try makeMedication(startDate: try date(day: 1))
        let otherLog = DoseLog(
            medicationId: UUID(),
            scheduledDate: try date(day: 17, hour: 9),
            status: .taken,
            recordedAt: try date(day: 17, hour: 9)
        )
        
        let today = try #require(
            try await makeSUT(logs: [otherLog]).execute(medication, endingOn: try date(day: 17, hour: 12), days: 1).first
        )
        
        #expect(today.takenCount == 0)
    }
    
    @Test func reportsTakenDoses() async throws {
        let medication = try makeMedication(times: [(9, 0), (21, 0)], startDate: try date(day: 1))
        let log = DoseLog(
            medicationId: medication.id,
            scheduledDate: try date(day: 17, hour: 9),
            status: .taken,
            recordedAt: try date(day: 17, hour: 9)
        )
        
        let today = try #require(
            try await makeSUT(logs: [log]).execute(medication, endingOn: try date(day: 17, hour: 23), days: 1).first
        )
        
        #expect(today.doses.count == 2)
        #expect(today.takenCount == 1)
    }
}
