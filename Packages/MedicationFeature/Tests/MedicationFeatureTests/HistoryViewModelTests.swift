//
//  HistoryViewModelTests.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
import Testing
@testable import MedicationFeature

@MainActor
struct HistoryViewModelTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int = 0, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeMedication(times: [(Int, Int)] = [(9, 0)]) throws -> Medication {
        let start = try date(day: 10)
        
        return Medication(
            name: "Vitamin D",
            dosage: Dosage(amount: 1, unit: .tablet),
            schedule: MedicationSchedule(
                times: try times.map { try MedTime(hour: $0.0, minute: $0.1) },
                startDate: start
            ),
            isActive: true,
            createdDate: start
        )
    }
    
    private func makeSUT(
        medications: [Medication],
        logRepository: MockDoseLogRepository = MockDoseLogRepository(),
        now: Date
    ) -> HistoryViewModel {
        HistoryViewModel(
            loadHistory: LoadDoseHistoryUseCase(
                medicationRepository: MockMedicationRepository(medications: medications),
                doseLogRepository: logRepository,
                calendar: calendar
            ),
            recordDose: RecordDoseUseCase(doseLogRepository: logRepository, calendar: calendar),
            currentDate: { now }
        )
    }
    
    @Test func loadsLastSevenDays() async throws {
        let sut = makeSUT(medications: [try makeMedication()], now: try date(day: 17, hour: 12))
        
        await sut.load()
        
        guard case .loaded(let summaries) = sut.state else {
            Issue.record("Expected loaded state, got \(sut.state)")
            return
        }
        
        #expect(summaries.count == 7)
        #expect(summaries.first?.date == (try date(day: 17)))
    }
    
    @Test func showsEmptyStateWithoutMedications() async throws {
        let sut = makeSUT(medications: [], now: try date(day: 17, hour: 12))
        
        await sut.load()
        
        #expect(sut.state == .empty)
    }
    
    @Test func reportsAdherenceAcrossLoadedDays() async throws {
        let medication = try makeMedication()
        let logRepository = MockDoseLogRepository(
            logs: [
                DoseLog(
                    medicationId: medication.id,
                    scheduledDate: try date(day: 17, hour: 9),
                    status: .taken,
                    recordedAt: try date(day: 17, hour: 9)
                )
            ]
        )
        let sut = makeSUT(medications: [medication], logRepository: logRepository, now: try date(day: 17, hour: 12))
        
        await sut.load()
        
        #expect(abs(sut.adherence - 1.0 / 7.0) < 0.0001)
    }
    
    @Test func recordingPastDoseUpdatesItsDay() async throws {
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication()],
            logRepository: logRepository,
            now: try date(day: 17, hour: 12)
        )
        
        await sut.load()
        
        guard case .loaded(let summaries) = sut.state,
              let yesterday = summaries.first(where: { $0.date == (try? date(day: 16)) }),
              let dose = yesterday.doses.first
        else {
            Issue.record("Expected a dose for the previous day")
            return
        }
        
        await sut.record(dose, as: .taken)
        
        guard case .loaded(let updated) = sut.state,
              let updatedDay = updated.first(where: { $0.date == (try? date(day: 16)) })
        else {
            Issue.record("Expected loaded state")
            return
        }
        
        #expect(updatedDay.takenCount == 1)
        #expect(await logRepository.logs.count == 1)
    }
    
    @Test func reportsErrorForDoseOutsideEditableRange() async throws {
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication()],
            logRepository: logRepository,
            now: try date(day: 17, hour: 12)
        )
        let staleDose = ScheduledDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 1, hour: 9)
        )
        
        await sut.record(staleDose, as: .taken)
        
        #expect(sut.errorMessage == "Doses can only be updated within the last 7 days.")
        #expect(await logRepository.logs.isEmpty)
    }
}
