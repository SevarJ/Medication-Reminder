//
//  LoadScheduledDoseUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

@testable import Domain
import Foundation
import Testing

struct LoadScheduledDoseUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    @Test func loadsDoseWithItsExistingLog() async throws {
        let medication = try makeMedication()
        let scheduledDate = try date(day: 17, hour: 9)
        let log = DoseLog(
            medicationId: medication.id,
            scheduledDate: scheduledDate,
            status: .skipped,
            recordedAt: scheduledDate
        )
        let sut = LoadScheduledDoseUseCase(
            medicationRepository: MockMedicationRepository(medications: [medication]),
            doseLogRepository: MockDoseLogRepository(logs: [log])
        )
        
        let dose = try await sut.execute(medicationId: medication.id, scheduledDate: scheduledDate)
        
        #expect(dose.medication == medication)
        #expect(dose.scheduledDate == scheduledDate)
        #expect(dose.log == log)
    }
    
    @Test func ignoresLogsOfOtherDoses() async throws {
        let medication = try makeMedication()
        let log = DoseLog(
            medicationId: medication.id,
            scheduledDate: try date(day: 17, hour: 21),
            status: .taken,
            recordedAt: try date(day: 17, hour: 21)
        )
        let sut = LoadScheduledDoseUseCase(
            medicationRepository: MockMedicationRepository(medications: [medication]),
            doseLogRepository: MockDoseLogRepository(logs: [log])
        )
        
        let dose = try await sut.execute(medicationId: medication.id, scheduledDate: try date(day: 17, hour: 9))
        
        #expect(dose.log == nil)
    }
    
    @Test func failsForUnknownMedication() async throws {
        let sut = LoadScheduledDoseUseCase(
            medicationRepository: MockMedicationRepository(),
            doseLogRepository: MockDoseLogRepository()
        )
        
        await #expect(throws: DomainError.medicationNotFound) {
            try await sut.execute(medicationId: UUID(), scheduledDate: try date(day: 17, hour: 9))
        }
    }
}
