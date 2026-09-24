//
//  LoadDoseHistoryUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

@testable import Domain
import Foundation
import Testing

struct LoadDoseHistoryUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int = 0, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeSUT(
        medications: [Medication],
        logs: [DoseLog] = []
    ) -> LoadDoseHistoryUseCase {
        LoadDoseHistoryUseCase(
            medicationRepository: MockMedicationRepository(medications: medications),
            doseLogRepository: MockDoseLogRepository(logs: logs),
            calendar: calendar
        )
    }
    
    @Test func returnsRequestedNumberOfDaysNewestFirst() async throws {
        let medication = try makeMedication(startDate: try date(day: 1))
        let sut = makeSUT(medications: [medication])
        
        let history = try await sut.execute(endingOn: try date(day: 17, hour: 12), days: 3)
        
        #expect(history.map { $0.date } == [try date(day: 17), try date(day: 16), try date(day: 15)])
    }
    
    @Test func skipsDaysWithoutScheduledDoses() async throws {
        let medication = try makeMedication(
            recurrence: .daysOfWeek([.wednesday]),
            startDate: try date(day: 1)
        )
        let sut = makeSUT(medications: [medication])
        
        let history = try await sut.execute(endingOn: try date(day: 17, hour: 12), days: 7)
        
        #expect(history.count == 1)
        #expect(history.first?.date == (try date(day: 16)))
    }
    
    @Test func reportsAdherencePerDay() async throws {
        let medication = try makeMedication(times: [(9, 0), (21, 0)], startDate: try date(day: 1))
        let logs = [
            DoseLog(
                medicationId: medication.id,
                scheduledDate: try date(day: 17, hour: 9),
                status: .taken,
                recordedAt: try date(day: 17, hour: 9)
            ),
            DoseLog(
                medicationId: medication.id,
                scheduledDate: try date(day: 17, hour: 21),
                status: .skipped,
                recordedAt: try date(day: 17, hour: 21)
            )
        ]
        let sut = makeSUT(medications: [medication], logs: logs)
        
        let today = try #require(
            try await sut.execute(endingOn: try date(day: 17, hour: 23), days: 1).first
        )
        
        #expect(today.doses.count == 2)
        #expect(today.takenCount == 1)
        #expect(today.adherence == 0.5)
    }
    
    @Test func excludesInactiveMedications() async throws {
        let sut = makeSUT(
            medications: [try makeMedication(startDate: try date(day: 1), isActive: false)]
        )
        
        #expect(try await sut.execute(endingOn: try date(day: 17, hour: 12)).isEmpty)
    }
}
