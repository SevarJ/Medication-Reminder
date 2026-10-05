//
//  MonthCalendarViewModelTests.swift
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
struct MonthCalendarViewModelTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    /// Mid-September, so the cached window starts on September 3.
    private var now: Date {
        get throws { try date(month: 9, day: 17, hour: 12) }
    }
    
    private func date(month: Int, day: Int, hour: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))
        )
    }
    
    private func makeLog(
        for medication: Medication,
        month: Int,
        day: Int,
        status: DoseStatus = .taken
    ) throws -> DoseLog {
        let scheduled = try date(month: month, day: day, hour: 9)
        
        return DoseLog(medicationId: medication.id, scheduledDate: scheduled, status: status, recordedAt: scheduled)
    }
    
    private func makeSUT(
        medication: Medication? = nil,
        cachedLogs: [DoseLog] = [],
        remote: MockDoseLogRemoteStore = MockDoseLogRemoteStore()
    ) throws -> MonthCalendarViewModel {
        let medications = try medication ?? makeMedication(startDate: try date(month: 8, day: 1))
        let now = try now
        
        return MonthCalendarViewModel(
            loadMonth: LoadMonthHistoryUseCase(
                medicationRepository: MockMedicationRepository(medications: [medications]),
                doseLogRepository: MockDoseLogRepository(logs: cachedLogs),
                remoteDoseLogs: remote,
                calendar: calendar
            ),
            calendar: calendar,
            currentDate: { now }
        )
    }
    
    @Test func startsOnTheCurrentMonth() async throws {
        let sut = try makeSUT()
        
        await sut.load()
        
        #expect(sut.month == (try date(month: 9, day: 1)))
        #expect(sut.days.count == 17)
    }
    
    @Test func showsAnOlderMonth() async throws {
        let sut = try makeSUT()
        
        await sut.load()
        await sut.showPreviousMonth()
        
        #expect(sut.month == (try date(month: 8, day: 1)))
        #expect(sut.days.count == 31)
    }
    
    @Test func keepsAnOlderMonthForTheRestOfTheSession() async throws {
        let remote = MockDoseLogRemoteStore()
        let sut = try makeSUT(remote: remote)
        
        await sut.load()
        await sut.showPreviousMonth()
        await sut.showNextMonth()
        
        let before = await remote.fetchCount
        
        await sut.showPreviousMonth()
        
        #expect(sut.days.count == 31)
        #expect(await remote.fetchCount == before)
    }
    
    @Test func reloadFetchesAnOlderMonthAgain() async throws {
        let remote = MockDoseLogRemoteStore()
        let sut = try makeSUT(remote: remote)
        
        await sut.load()
        await sut.showPreviousMonth()
        
        let before = await remote.fetchCount
        
        await sut.reload()
        
        #expect(await remote.fetchCount == before + 1)
    }
    
    @Test func failsWhenAnOlderMonthCannotBeReached() async throws {
        let sut = try makeSUT(remote: MockDoseLogRemoteStore(fails: true))
        
        await sut.load()
        await sut.showPreviousMonth()
        
        #expect(sut.state == .failure)
        #expect(sut.days.isEmpty)
    }
    
    @Test func recoversOnceTheServerAnswers() async throws {
        let remote = MockDoseLogRemoteStore()
        let sut = try makeSUT(remote: remote)
        
        await sut.load()
        await sut.showPreviousMonth()
        await sut.reload()
        
        #expect(sut.state != .failure)
        #expect(sut.days.count == 31)
    }
    
    @Test func cannotLookPastTheCurrentMonth() async throws {
        let sut = try makeSUT()
        
        await sut.load()
        await sut.showNextMonth()
        
        #expect(!sut.canShowNextMonth)
        #expect(sut.month == (try date(month: 9, day: 1)))
    }
    
    @Test func cannotLookBeforeTheFirstMedication() async throws {
        let sut = try makeSUT()
        
        await sut.load()
        
        #expect(sut.canShowPreviousMonth)
        
        await sut.showPreviousMonth()
        await sut.showPreviousMonth()
        
        #expect(sut.month == (try date(month: 8, day: 1)))
        #expect(!sut.canShowPreviousMonth)
    }
    
    @Test func cannotLookBackWithoutMedications() async throws {
        let now = try now
        let sut = MonthCalendarViewModel(
            loadMonth: LoadMonthHistoryUseCase(
                medicationRepository: MockMedicationRepository(),
                doseLogRepository: MockDoseLogRepository(),
                remoteDoseLogs: MockDoseLogRemoteStore(),
                calendar: calendar
            ),
            calendar: calendar,
            currentDate: { now }
        )
        
        await sut.load()
        
        #expect(!sut.canShowPreviousMonth)
    }
    
    @Test func canReturnToTheCurrentMonth() async throws {
        let sut = try makeSUT()
        
        await sut.load()
        await sut.showPreviousMonth()
        
        #expect(sut.canShowNextMonth)
    }
    
    @Test func countsDosesThatHaveComeDue() async throws {
        let medication = try makeMedication(startDate: try date(month: 9, day: 1))
        let cached = [
            try makeLog(for: medication, month: 9, day: 10),
            try makeLog(for: medication, month: 9, day: 11, status: .skipped)
        ]
        let sut = try makeSUT(medication: medication, cachedLogs: cached)
        
        await sut.load()
        
        #expect(sut.takenCount == 1)
        #expect(sut.skippedCount == 1)
        #expect(sut.missedCount == 15)
        #expect(sut.adherence == 1.0 / 17.0)
    }
    
    @Test func hasNoAdherenceBeforeAnyDoseIsDue() async throws {
        let medication = try makeMedication(startDate: try date(month: 9, day: 20))
        let sut = try makeSUT(medication: medication)
        
        await sut.load()
        
        #expect(sut.adherence == nil)
    }
    
    @Test func endsToday() async throws {
        let sut = try makeSUT()
        
        #expect(!sut.isSelectable(try date(month: 9, day: 25)))
        #expect(sut.isSelectable(try date(month: 9, day: 17, hour: 23)))
        #expect(sut.isSelectable(try date(month: 9, day: 3)))
    }
    
    @Test func selectsNothingInAMonthWithoutDoses() async throws {
        let medication = try makeMedication(
            startDate: try date(month: 7, day: 15),
            endDate: try date(month: 7, day: 20)
        )
        let sut = try makeSUT(medication: medication)
        
        await sut.load()
        await sut.showPreviousMonth()
        
        #expect(sut.days.isEmpty)
    }
    
    @Test func reportsTheOutcomeOfEachDay() async throws {
        let medication = try makeMedication(startDate: try date(month: 9, day: 1))
        let sut = try makeSUT(
            medication: medication,
            cachedLogs: [try makeLog(for: medication, month: 9, day: 10)]
        )
        
        await sut.load()
        
        #expect(sut.outcome(on: try date(month: 9, day: 10)) == .complete)
        #expect(sut.outcome(on: try date(month: 9, day: 11)) == .missed)
        #expect(sut.outcome(on: try date(month: 9, day: 18)) == .none)
    }
    
    @Test func padsTheGridUpToTheFirstWeekday() async throws {
        let sut = try makeSUT()
        
        // September 2026 starts on a Tuesday and this calendar's week starts on Sunday.
        #expect(sut.gridDays.prefix(3).map { $0 == nil } == [true, true, false])
        #expect(sut.gridDays.compactMap { $0 }.count == 30)
        #expect(sut.weekdayHeaders.count == 7)
    }
    
    @Test func showsTheMonthOfAGivenDay() async throws {
        let sut = try makeSUT()
        
        await sut.load()
        await sut.showMonth(containing: try date(month: 8, day: 14, hour: 15))
        
        #expect(sut.month == (try date(month: 8, day: 1)))
        #expect(sut.days.count == 31)
    }
    
    @Test func replacesARecordedDose() async throws {
        let medication = try makeMedication(startDate: try date(month: 9, day: 1))
        let sut = try makeSUT(medication: medication)
        
        await sut.load()
        
        let dose = try #require(sut.summary(on: try date(month: 9, day: 10))?.doses.first)
        let log = try makeLog(for: medication, month: 9, day: 10)
        
        sut.replace(ScheduledDose(medication: dose.medication, scheduledDate: dose.scheduledDate, log: log))
        
        #expect(sut.summary(on: try date(month: 9, day: 10))?.takenCount == 1)
        #expect(sut.takenCount == 1)
    }
}
