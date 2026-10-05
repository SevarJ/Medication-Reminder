//
//  MedicationDetailViewModelTests.swift
//  DashboardImplTests
//
//  Created by Sevar Jafarli on 05.10.26.
//

import Domain
import DomainTesting
import Foundation
import Testing
@testable import DashboardImpl

@MainActor
struct MedicationDetailViewModelTests {
    private let calendar = Calendar.current
    private let now = Date(timeIntervalSince1970: 1_790_000_000)
    
    @Test func loadsHistoryOfTheMedication() async throws {
        let medication = try makeMedication(startDate: now.addingTimeInterval(-3 * 86_400))
        let sut = makeSUT(medication: medication)
        
        await sut.load()
        
        #expect(sut.history.count == 7)
        #expect(sut.history.allSatisfy { $0.doses.allSatisfy { $0.medication.id == medication.id } })
    }
    
    @Test func countsTakenSkippedAndMissedDoses() async throws {
        let medication = try makeMedication(times: [(9, 0)], startDate: now.addingTimeInterval(-5 * 86_400))
        let doses = try dueDoseDates(of: medication)
        let logs = [
            DoseLog(medicationId: medication.id, scheduledDate: doses[0], status: .taken, recordedAt: doses[0]),
            DoseLog(medicationId: medication.id, scheduledDate: doses[1], status: .skipped, recordedAt: doses[1])
        ]
        let sut = makeSUT(medication: medication, logs: logs)
        
        await sut.load()
        
        #expect(sut.takenCount == 1)
        #expect(sut.skippedCount == 1)
        #expect(sut.missedCount == doses.count - 2)
        #expect(sut.adherence == 1 / Double(doses.count))
    }
    
    @Test func adherenceIsZeroWithoutDueDoses() async throws {
        let medication = try makeMedication(startDate: now.addingTimeInterval(86_400 * 30))
        let sut = makeSUT(medication: medication)
        
        await sut.load()
        
        #expect(sut.dueDoses.isEmpty)
        #expect(sut.adherence == 0)
    }
    
    @Test func togglingFlipsActiveState() async throws {
        let medication = try makeMedication(isActive: true)
        let sut = makeSUT(medication: medication)
        
        await sut.toggle()
        
        #expect(sut.medication.isActive == false)
    }
    
    @Test func togglingKeepsTheNewStateWhenSchedulingIsDenied() async throws {
        let medication = try makeMedication(isActive: false)
        let sut = makeSUT(
            medication: medication,
            scheduler: MockReminderScheduler(failsWithAuthorizationDenied: true)
        )
        
        await sut.toggle()
        
        #expect(sut.medication.isActive)
        #expect(sut.errorMessage == nil)
    }
    
    @Test func deletingRemovesMedicationFromTheRepository() async throws {
        let medication = try makeMedication()
        let repository = MockMedicationRepository(medications: [medication])
        let sut = makeSUT(medication: medication, repository: repository)
        
        #expect(await sut.delete())
        #expect(try await repository.fetchAll().isEmpty)
    }
    
    private func dueDoseDates(of medication: Medication) throws -> [Date] {
        let days = LoadDoseHistoryUseCase.defaultDayCount
        let lastDay = calendar.startOfDay(for: now)
        
        return (0..<days)
            .compactMap { calendar.date(byAdding: .day, value: -$0, to: lastDay) }
            .flatMap { medication.schedule.doses(on: $0, calendar: calendar) }
            .filter { $0 <= now }
            .sorted(by: >)
    }
    
    private func makeSUT(
        medication: Medication,
        repository: MockMedicationRepository? = nil,
        logs: [DoseLog] = [],
        scheduler: MockReminderScheduler = MockReminderScheduler()
    ) -> MedicationDetailViewModel {
        let repository = repository ?? MockMedicationRepository(medications: [medication])
        let logRepository = MockDoseLogRepository(logs: logs)
        let saveMedication = SaveMedicationUseCase(repository: repository, scheduler: scheduler)
        let now = now
        
        return MedicationDetailViewModel(
            medication: medication,
            repository: repository,
            loadHistory: LoadMedicationHistoryUseCase(doseLogRepository: logRepository),
            saveMedication: saveMedication,
            deleteMedication: DeleteMedicationUseCase(
                repository: repository,
                scheduler: scheduler,
                doseLogRepository: logRepository
            ),
            toggleMedicationActive: ToggleMedicationActiveUseCase(saveMedication: saveMedication),
            currentDate: { now }
        )
    }
}
