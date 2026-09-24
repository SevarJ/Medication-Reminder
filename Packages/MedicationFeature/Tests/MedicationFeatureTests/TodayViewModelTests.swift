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
    
    private func date(day: Int, hour: Int = 0, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))
        )
    }
    
    private func makeMedication(
        name: String = "Vitamin D",
        times: [(Int, Int)] = [(9, 0)],
        startDay: Int = 1
    ) throws -> Medication {
        let start = try date(day: startDay)
        
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
            loadHistory: LoadDoseHistoryUseCase(
                medicationRepository: medicationRepository,
                doseLogRepository: doseLogRepository,
                calendar: calendar
            ),
            recordDose: RecordDoseUseCase(
                doseLogRepository: doseLogRepository,
                calendar: calendar
            ),
            saveMedication: SaveMedicationUseCase(
                repository: medicationRepository,
                scheduler: MockReminderScheduler()
            ),
            calendar: calendar,
            currentDate: { now }
        )
    }
    
    private func takenLog(for medication: Medication, day: Int, hour: Int) throws -> DoseLog {
        DoseLog(
            medicationId: medication.id,
            scheduledDate: try date(day: day, hour: hour),
            status: .taken,
            recordedAt: try date(day: day, hour: hour)
        )
    }
    
    @Test func loadsSevenDaysEndingToday() async throws {
        let sut = makeSUT(medications: [try makeMedication()], now: try date(day: 17, hour: 12))
        
        await sut.load()
        
        #expect(sut.week.map(\.date) == (try (11...17).map { try date(day: $0) }))
        #expect(sut.isTodaySelected)
    }
    
    @Test func keepsDaysWithoutDosesInTheWeek() async throws {
        let sut = makeSUT(medications: [try makeMedication(startDay: 16)], now: try date(day: 17, hour: 12))
        
        await sut.load()
        
        #expect(sut.week.count == 7)
        #expect(sut.week.filter { $0.doses.isEmpty }.count == 5)
    }
    
    @Test func loadsTodaysDoses() async throws {
        let sut = makeSUT(
            medications: [try makeMedication(times: [(9, 0), (21, 0)])],
            now: try date(day: 16, hour: 12)
        )
        
        await sut.load()
        
        let doses = sut.selectedDoses
        
        #expect(doses.count == 2)
        #expect(sut.state(of: doses[0]) == .missed)
        #expect(sut.state(of: doses[1]) == .pending)
    }
    
    @Test func selectingPastDayShowsItsDoses() async throws {
        let medication = try makeMedication()
        let sut = makeSUT(
            medications: [medication],
            logs: [try takenLog(for: medication, day: 15, hour: 9)],
            now: try date(day: 16, hour: 12)
        )
        
        await sut.load()
        sut.select(try date(day: 15, hour: 18))
        
        #expect(sut.isTodaySelected == false)
        #expect(sut.selectedDoses.first?.scheduledDate == (try date(day: 15, hour: 9)))
        #expect(sut.takenCount == 1)
        #expect(sut.nextDose == nil)
    }
    
    @Test func reportsProgressForSelectedDay() async throws {
        let medication = try makeMedication(times: [(8, 0), (9, 0), (20, 0), (21, 0)])
        let sut = makeSUT(
            medications: [medication],
            logs: [try takenLog(for: medication, day: 16, hour: 8)],
            now: try date(day: 16, hour: 12)
        )
        
        await sut.load()
        
        #expect(sut.takenCount == 1)
        #expect(sut.progress == 0.25)
        #expect(sut.isDayComplete == false)
    }
    
    @Test func reportsAdherenceAcrossTheWeek() async throws {
        let medication = try makeMedication()
        let sut = makeSUT(
            medications: [medication],
            logs: [try takenLog(for: medication, day: 17, hour: 9)],
            now: try date(day: 17, hour: 12)
        )
        
        await sut.load()
        
        #expect(abs(sut.weekAdherence - 1.0 / 7.0) < 0.0001)
    }
    
    @Test func nextDoseIsEarliestPendingDoseToday() async throws {
        let sut = makeSUT(
            medications: [
                try makeMedication(name: "Evening", times: [(21, 0)]),
                try makeMedication(name: "Afternoon", times: [(9, 0), (15, 0)])
            ],
            now: try date(day: 16, hour: 12)
        )
        
        await sut.load()
        
        #expect(sut.nextDose?.medication.name == "Afternoon")
        #expect(sut.nextDose?.scheduledDate == (try date(day: 16, hour: 15)))
    }
    
    @Test func dayIsCompleteOnceEveryDoseIsTaken() async throws {
        let medication = try makeMedication()
        let sut = makeSUT(medications: [medication], now: try date(day: 16, hour: 8))
        
        await sut.load()
        
        let dose = try #require(sut.nextDose)
        
        await sut.record(dose, as: .taken)
        
        #expect(sut.isDayComplete)
        #expect(sut.nextDose == nil)
    }
    
    @Test func recordingTakenUpdatesOnlyThatDose() async throws {
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication(times: [(9, 0), (21, 0)])],
            logRepository: logRepository,
            now: try date(day: 16, hour: 12)
        )
        
        await sut.load()
        await sut.record(sut.selectedDoses[0], as: .taken)
        
        let updated = sut.selectedDoses
        
        #expect(sut.state(of: updated[0]) == .taken)
        #expect(sut.state(of: updated[1]) == .pending)
        #expect(await logRepository.logs.count == 1)
    }
    
    @Test func recordingPastDoseUpdatesItsDay() async throws {
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication()],
            logRepository: logRepository,
            now: try date(day: 17, hour: 12)
        )
        
        await sut.load()
        sut.select(try date(day: 16))
        
        await sut.record(try #require(sut.selectedDoses.first), as: .taken)
        
        #expect(sut.takenCount == 1)
        #expect(sut.week.last?.takenCount == 0)
        #expect(await logRepository.logs.count == 1)
    }
    
    @Test func recordingSameStatusTwiceClearsTheDose() async throws {
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication()],
            logRepository: logRepository,
            now: try date(day: 16, hour: 12)
        )
        
        await sut.load()
        await sut.record(sut.selectedDoses[0], as: .taken)
        await sut.record(sut.selectedDoses[0], as: .taken)
        
        #expect(sut.state(of: sut.selectedDoses[0]) == .missed)
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
        let logRepository = MockDoseLogRepository()
        let sut = makeSUT(
            medications: [try makeMedication()],
            logRepository: logRepository,
            now: try date(day: 16, hour: 12)
        )
        let staleDose = ScheduledDose(
            medication: try makeMedication(),
            scheduledDate: try date(day: 1, hour: 9)
        )
        
        await sut.record(staleDose, as: .taken)
        
        #expect(sut.errorMessage == "Doses can only be updated within the last 7 days.")
        #expect(await logRepository.logs.isEmpty)
    }
    
    @Test func addingMedicationShowsItsDosesAfterReload() async throws {
        let repository = MockMedicationRepository()
        let sut = makeSUT(medications: [], repository: repository, now: try date(day: 16, hour: 8))
        
        await sut.load()
        
        let editor = sut.makeNewMedicationEditor()
        editor.name = "Omega 3"
        editor.startDate = try date(day: 1)
        
        #expect(editor.isEditing == false)
        #expect(await editor.save())
        
        await sut.load()
        
        #expect(sut.selectedDoses.map(\.medication.name) == ["Omega 3"])
    }
    
    @Test func groupsDosesByPeriod() async throws {
        let sut = makeSUT(
            medications: [try makeMedication(times: [(8, 0), (14, 0), (21, 0)])],
            now: try date(day: 16, hour: 12)
        )
        
        await sut.load()
        
        #expect(sut.doses(in: .morning).count == 1)
        #expect(sut.doses(in: .afternoon).count == 1)
        #expect(sut.doses(in: .evening).count == 1)
    }
}
