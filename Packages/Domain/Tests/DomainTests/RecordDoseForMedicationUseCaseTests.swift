//
//  RecordDoseForMedicationUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

@testable import Domain
import Foundation
import Testing

struct RecordDoseForMedicationUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeSUT(
        medications: [Medication],
        logRepository: MockDoseLogRepository
    ) -> RecordDoseForMedicationUseCase {
        RecordDoseForMedicationUseCase(
            medicationRepository: MockMedicationRepository(medications: medications),
            doseLogRepository: logRepository,
            recordDose: RecordDoseUseCase(doseLogRepository: logRepository, calendar: calendar)
        )
    }
    
    @Test func recordsDoseForKnownMedication() async throws {
        let medication = try makeMedication()
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(medications: [medication], logRepository: logRepository)
        let scheduledDate = try date(day: 17, hour: 9)
        
        let dose = try await sut.execute(
            medicationId: medication.id,
            scheduledDate: scheduledDate,
            status: .taken,
            now: try date(day: 17, hour: 9, minute: 5)
        )
        
        #expect(dose.log?.status == .taken)
        #expect(await logRepository.logs.count == 1)
    }
    
    @Test func togglesExistingLogInsteadOfAddingAnother() async throws {
        let medication = try makeMedication()
        let scheduledDate = try date(day: 17, hour: 9)
        let logRepository = MockDoseLogRepository(
            logs: [
                DoseLog(
                    medicationId: medication.id,
                    scheduledDate: scheduledDate,
                    status: .taken,
                    recordedAt: scheduledDate
                )
            ]
        )
        let sut = makeSUT(medications: [medication], logRepository: logRepository)
        
        let dose = try await sut.execute(
            medicationId: medication.id,
            scheduledDate: scheduledDate,
            status: .taken,
            now: try date(day: 17, hour: 10)
        )
        
        #expect(dose.log == nil)
        #expect(await logRepository.logs.isEmpty)
    }
    
    @Test func failsForUnknownMedication() async throws {
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(medications: [], logRepository: logRepository)
        
        await #expect(throws: DomainError.medicationNotFound) {
            try await sut.execute(
                medicationId: UUID(),
                scheduledDate: try date(day: 17, hour: 9),
                status: .taken,
                now: try date(day: 17, hour: 10)
            )
        }
    }
}
