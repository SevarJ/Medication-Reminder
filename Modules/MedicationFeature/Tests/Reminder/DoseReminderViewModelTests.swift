//
//  DoseReminderViewModelTests.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
import Testing
@testable import MedicationFeature

@MainActor
struct DoseReminderViewModelTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(day: Int, hour: Int, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeSUT(
        medicationId: UUID,
        medications: [Medication],
        logRepository: MockDoseLogRepository = MockDoseLogRepository(),
        scheduler: MockReminderScheduler = MockReminderScheduler()
    ) throws -> DoseReminderViewModel {
        let repository = MockMedicationRepository(medications: medications)
        let now = try date(day: 17, hour: 9, minute: 5)
        
        return DoseReminderViewModel(
            medicationId: medicationId,
            scheduledDate: try date(day: 17, hour: 9),
            loadDose: LoadScheduledDoseUseCase(medicationRepository: repository, doseLogRepository: logRepository),
            recordDose: RecordDoseUseCase(doseLogRepository: logRepository, calendar: calendar),
            snoozeReminder: SnoozeReminderUseCase(repository: repository, scheduler: scheduler),
            snoozeDelay: 5 * 60,
            currentDate: { now }
        )
    }
    
    @Test func loadsTheNotifiedDose() async throws {
        let medication = try makeMedication()
        let sut = try makeSUT(medicationId: medication.id, medications: [medication])
        
        await sut.load()
        
        guard case .loaded(let dose) = sut.state else {
            Issue.record("Expected loaded state, got \(sut.state)")
            return
        }
        
        #expect(dose.medication == medication)
        #expect(dose.scheduledDate == (try date(day: 17, hour: 9)))
        #expect(dose.log == nil)
    }
    
    @Test func reportsFailureForDeletedMedication() async throws {
        let sut = try makeSUT(medicationId: UUID(), medications: [])
        
        await sut.load()
        
        #expect(sut.state == .failure(message: "This medication no longer exists."))
    }
    
    @Test func takingRecordsDoseAndFinishes() async throws {
        let medication = try makeMedication()
        let logRepository = MockDoseLogRepository()
        let sut = try makeSUT(medicationId: medication.id, medications: [medication], logRepository: logRepository)
        
        await sut.load()
        await sut.take()
        
        guard case .loaded(let dose) = sut.state else {
            Issue.record("Expected loaded state")
            return
        }
        
        #expect(dose.log?.status == .taken)
        #expect(sut.isFinished)
        #expect(await logRepository.logs.map(\.status) == [.taken])
    }
    
    @Test func takingAlreadyTakenDoseKeepsIt() async throws {
        let medication = try makeMedication()
        let scheduledDate = try date(day: 17, hour: 9)
        let logRepository = MockDoseLogRepository(
            logs: [DoseLog(medicationId: medication.id, scheduledDate: scheduledDate, status: .taken, recordedAt: scheduledDate)]
        )
        let sut = try makeSUT(medicationId: medication.id, medications: [medication], logRepository: logRepository)
        
        await sut.load()
        await sut.take()
        
        #expect(await logRepository.logs.map(\.status) == [.taken])
    }
    
    @Test func takingReplacesSkippedDose() async throws {
        let medication = try makeMedication()
        let scheduledDate = try date(day: 17, hour: 9)
        let logRepository = MockDoseLogRepository(
            logs: [DoseLog(medicationId: medication.id, scheduledDate: scheduledDate, status: .skipped, recordedAt: scheduledDate)]
        )
        let sut = try makeSUT(medicationId: medication.id, medications: [medication], logRepository: logRepository)
        
        await sut.load()
        await sut.take()
        
        #expect(await logRepository.logs.map(\.status) == [.taken])
    }
    
    @Test func snoozingSchedulesReminderWithoutRecording() async throws {
        let medication = try makeMedication()
        let logRepository = MockDoseLogRepository()
        let scheduler = MockReminderScheduler()
        let sut = try makeSUT(
            medicationId: medication.id,
            medications: [medication],
            logRepository: logRepository,
            scheduler: scheduler
        )
        
        await sut.load()
        await sut.snooze()
        
        #expect(sut.snoozeMinutes == 5)
        #expect(sut.isFinished)
        #expect(await scheduler.snoozedIds == [medication.id])
        #expect(await logRepository.logs.isEmpty)
    }
}
