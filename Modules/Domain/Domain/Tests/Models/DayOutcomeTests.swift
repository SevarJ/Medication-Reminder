//
//  DayOutcomeTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 05.10.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct DayOutcomeTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(hour: Int) throws -> Date {
        try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 17, hour: hour)))
    }
    
    /// A day with doses at 09:00 and 21:00. `statuses` lists the logged status of each, nil for none.
    private func makeDay(_ statuses: [DoseStatus?]) throws -> DoseDaySummary {
        let hours = [9, 21]
        let medication = try makeMedication(times: [(9, 0), (21, 0)], startDate: try date(hour: 0))
        let doses = try zip(hours, statuses).map { hour, status in
            let scheduled = try date(hour: hour)
            
            return ScheduledDose(
                medication: medication,
                scheduledDate: scheduled,
                log: status.map {
                    DoseLog(medicationId: medication.id, scheduledDate: scheduled, status: $0, recordedAt: scheduled)
                }
            )
        }
        
        return DoseDaySummary(date: try date(hour: 0), doses: doses)
    }
    
    @Test func isNoneWithoutDoses() throws {
        let day = DoseDaySummary(date: try date(hour: 0), doses: [])
        
        #expect(day.outcome(at: try date(hour: 23)) == .none)
    }
    
    @Test func isCompleteWhenEveryDoseIsTaken() throws {
        #expect(try makeDay([.taken, .taken]).outcome(at: try date(hour: 23)) == .complete)
    }
    
    @Test func isPartialWhenSomeDosesAreTaken() throws {
        #expect(try makeDay([.taken, nil]).outcome(at: try date(hour: 23)) == .partial)
    }
    
    @Test func isPartialWhenTheDayIsStillInProgress() throws {
        #expect(try makeDay([.taken, nil]).outcome(at: try date(hour: 12)) == .partial)
    }
    
    @Test func isUpcomingWhenEveryDoseIsAhead() throws {
        #expect(try makeDay([nil, nil]).outcome(at: try date(hour: 8)) == .upcoming)
    }
    
    @Test func isMissedWhenNothingWasTaken() throws {
        #expect(try makeDay([nil, nil]).outcome(at: try date(hour: 23)) == .missed)
    }
    
    @Test func isMissedWhenEveryDoseWasSkipped() throws {
        #expect(try makeDay([.skipped, .skipped]).outcome(at: try date(hour: 23)) == .missed)
    }
}
