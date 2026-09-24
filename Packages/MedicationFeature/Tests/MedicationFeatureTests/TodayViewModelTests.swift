//
//  TodayViewModelTests.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
import Testing
@testable import MedicationFeature

@MainActor
struct TodayViewModelTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeMedication(
        name: String = "Vitamin D",
        times: [(Int, Int)] = [(9, 0)],
        startDay: Int = 1
    ) throws -> Medication {
        let start = try date(day: startDay, hour: 0)
        
        return Medication(
            name: name,
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
        logs: [DoseLog] = [],
        repository: MockMedicationRepository? = nil,
        logRepository: MockDoseLogRepository? = nil,
        now: Date
    ) -> TodayViewModel {
        let medicationRepository = repository ?? MockMedicationRepository(medications: medications)
        let doseLogRepository = logRepository ?? MockDoseLogRepository(logs: logs)
        
        return TodayViewModel(
            loadDoses: LoadDosesUseCase(
                medicationRepository: medicationRepository,
                doseLogRepository: doseLogRepository,
                calendar: calendar
            ),
            recordDose: RecordDoseUseCase(
                doseLogRepository: doseLogRepository,
                calendar: calendar
            ),
            currentDate: { now }
        )
    }
    
    @Test func loadsTodaysDoses() async throws {
        let now = try date(day: 16, hour: 12)
        let sut = makeSUT(
            medications: [try makeMedication(times: [(9, 0), (21, 0)])],
            now: now
        )
        
        await sut.load()
        
        guard case .loaded(let doses) = sut.state else {
            Issue.record("Expected loaded state, got \(sut.state)")
            return
        }
        
        #expect(doses.count == 2)
        #expect(sut.state(of: doses[0]) == .missed)
        #expect(sut.state(of: doses[1]) == .pending)
    }
    
    @Test func showsEmptyStateWhenNothingIsScheduled() async throws {
        let sut = makeSUT(medications: [], now: try date(day: 16, hour: 12))
        
        await sut.load()
        
        #expect(sut.state == .empty)
    }
    
    @Test func recordingTakenUpdatesOnlyThatDose() async throws {
        let now = try date(day: 16, hour: 12)
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication(times: [(9, 0), (21, 0)])],
            logRepository: logRepository,
            now: now
        )
        
        await sut.load()
        
        guard case .loaded(let doses) = sut.state else {
            Issue.record("Expected loaded state")
            return
        }
        
        await sut.record(doses[0], as: .taken)
        
        guard case .loaded(let updated) = sut.state else {
            Issue.record("Expected loaded state")
            return
        }
        
        #expect(sut.state(of: updated[0]) == .taken)
        #expect(sut.state(of: updated[1]) == .pending)
        #expect(await logRepository.logs.count == 1)
    }
    
    @Test func recordingSameStatusTwiceClearsTheDose() async throws {
        let now = try date(day: 16, hour: 12)
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication()],
            logRepository: logRepository,
            now: now
        )
        
        await sut.load()
        
        guard case .loaded(let doses) = sut.state else {
            Issue.record("Expected loaded state")
            return
        }
        
        await sut.record(doses[0], as: .taken)
        
        guard case .loaded(let taken) = sut.state else {
            Issue.record("Expected loaded state")
            return
        }
        
        await sut.record(taken[0], as: .taken)
        
        guard case .loaded(let cleared) = sut.state else {
            Issue.record("Expected loaded state")
            return
        }
        
        #expect(sut.state(of: cleared[0]) == .missed)
        #expect(await logRepository.logs.isEmpty)
    }
    
    @Test func reportsFailureStateWhenLoadingFails() async throws {
        let sut = makeSUT(
            medications: [],
            repository: MockMedicationRepository(fetchAllFails: true),
            now: try date(day: 16, hour: 12)
        )
        
        await sut.load()
        
        #expect(sut.state == .failure(message: "Something went wrong. Please try again."))
        #expect(sut.errorMessage == nil)
    }
    
    @Test func reportsErrorWhenDoseIsOutsideEditableRange() async throws {
        let now = try date(day: 16, hour: 12)
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication()],
            logRepository: logRepository,
            now: now
        )
        let staleDose = ScheduledDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 1, hour: 9)
        )
        
        await sut.record(staleDose, as: .taken)
        
        #expect(sut.errorMessage == "Doses can only be updated within the last 7 days.")
        #expect(await logRepository.logs.isEmpty)
    }
    
    @Test func groupsDosesByPeriod() async throws {
        let now = try date(day: 16, hour: 12)
        let sut = makeSUT(
            medications: [try makeMedication(times: [(8, 0), (14, 0), (21, 0)])],
            now: now
        )
        
        await sut.load()
        
        guard case .loaded(let doses) = sut.state else {
            Issue.record("Expected loaded state")
            return
        }
        
        #expect(sut.doses(in: .morning, from: doses).count == 1)
        #expect(sut.doses(in: .afternoon, from: doses).count == 1)
        #expect(sut.doses(in: .evening, from: doses).count == 1)
    }
}
