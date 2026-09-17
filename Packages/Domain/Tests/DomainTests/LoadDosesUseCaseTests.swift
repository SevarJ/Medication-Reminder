//
//  LoadDosesUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 17.09.26.
//

@testable import Domain
import Foundation
import Testing

struct LoadDosesUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int, minute: Int) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeSUT(
        medications: [Medication],
        logs: [DoseLog] = []
    ) -> LoadDosesUseCase {
        LoadDosesUseCase(
            medicationRepository: MockMedicationRepository(medications: medications),
            doseLogRepository: MockDoseLogRepository(logs: logs),
            calendar: calendar
        )
    }
    
    @Test func excludesInactiveMedications() async throws {
        let medication = try makeMedication(
            startDate: try date(day: 1, hour: 0, minute: 0),
            isActive: false
        )
        let sut = makeSUT(medications: [medication])
        
        let doses = try await sut.execute(on: try date(day: 16, hour: 12, minute: 0))
        
        #expect(doses.isEmpty)
    }
    
    @Test func excludesMedicationsNotScheduledThatDay() async throws {
        let medication = try makeMedication(
            recurrence: .daysOfWeek([.monday]),
            startDate: try date(day: 1, hour: 0, minute: 0)
        )
        let sut = makeSUT(medications: [medication])
        
        let doses = try await sut.execute(on: try date(day: 16, hour: 12, minute: 0))
        
        #expect(doses.isEmpty)
    }
    
    @Test func attachesLogToMatchingDose() async throws {
        let medication = try makeMedication(
            times: [(9, 0), (21, 0)],
            startDate: try date(day: 1, hour: 0, minute: 0)
        )
        let log = DoseLog(
            medicationId: medication.id,
            scheduledDate: try date(day: 16, hour: 9, minute: 0),
            status: .taken,
            recordedAt: try date(day: 16, hour: 9, minute: 5)
        )
        let sut = makeSUT(medications: [medication], logs: [log])
        
        let doses = try await sut.execute(on: try date(day: 16, hour: 12, minute: 0))
        
        #expect(doses.count == 2)
        #expect(doses[0].log == log)
        #expect(doses[1].log == nil)
    }
    
    @Test func sortsDosesByTime() async throws {
        let evening = try makeMedication(
            name: "Magnesium",
            times: [(21, 0)],
            startDate: try date(day: 1, hour: 0, minute: 0)
        )
        let morning = try makeMedication(
            name: "Vitamin D",
            times: [(9, 0)],
            startDate: try date(day: 1, hour: 0, minute: 0)
        )
        let sut = makeSUT(medications: [evening, morning])
        
        let doses = try await sut.execute(on: try date(day: 16, hour: 12, minute: 0))
        
        #expect(doses.map { $0.medication.name } == ["Vitamin D", "Magnesium"])
    }
}
