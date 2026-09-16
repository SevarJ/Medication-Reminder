//
//  MedicationScheduleTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 12.09.26.
//

@testable import Domain
import Foundation
import Testing

struct MedicationScheduleTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func date(_ day: Int) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: day))
        )
    }
    
    private func makeSchedule(
        times: [(Int, Int)] = [(9, 0)],
        recurrence: Recurrence = .daily,
        startDay: Int = 7,
        endDay: Int? = nil
    ) throws -> MedicationSchedule {
        MedicationSchedule(
            times: try times.map { try MedTime(hour: $0.0, minute: $0.1) },
            recurrence: recurrence,
            startDate: try date(startDay),
            endDate: try endDay.map { try date($0) }
        )
    }
    
    @Test func dailyScheduleOccursEveryDayFromStart() async throws {
        let sut = try makeSchedule(startDay: 7)
        
        #expect(sut.occurs(on: try date(6), calendar: calendar) == false)
        #expect(sut.occurs(on: try date(7), calendar: calendar))
        #expect(sut.occurs(on: try date(8), calendar: calendar))
    }
    
    @Test func scheduleStopsAfterEndDate() async throws {
        let sut = try makeSchedule(startDay: 7, endDay: 9)
        
        #expect(sut.occurs(on: try date(9), calendar: calendar))
        #expect(sut.occurs(on: try date(10), calendar: calendar) == false)
    }
    
    @Test func weekdayScheduleOccursOnSelectedDaysOnly() async throws {
        let sut = try makeSchedule(recurrence: .daysOfWeek([.monday, .friday]))
        
        #expect(sut.occurs(on: try date(7), calendar: calendar))
        #expect(sut.occurs(on: try date(8), calendar: calendar) == false)
        #expect(sut.occurs(on: try date(11), calendar: calendar))
    }
    
    @Test func dosesReturnSortedTimesOfTheDay() async throws {
        let sut = try makeSchedule(times: [(21, 30), (8, 0)])
        
        let doses = sut.doses(on: try date(8), calendar: calendar)
        let components = doses.map { calendar.dateComponents([.hour, .minute], from: $0) }
        
        #expect(components.map { $0.hour } == [8, 21])
        #expect(components.map { $0.minute } == [0, 30])
    }
    
    @Test func dosesAreEmptyWhenScheduleDoesNotOccur() async throws {
        let sut = try makeSchedule(recurrence: .daysOfWeek([.monday]))
        
        #expect(sut.doses(on: try date(8), calendar: calendar).isEmpty)
    }
}
