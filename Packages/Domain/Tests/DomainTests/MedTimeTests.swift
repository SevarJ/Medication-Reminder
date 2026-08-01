//
//  MedTimeTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Testing
@testable import Domain

struct MedTimeTests {
    @Test func medTimeInvalidHourValidMinute() {
        #expect(throws: DomainError.invalidTime) {
            try MedTime(hour: 24, minute: 0)
        }
    }
    
    @Test func medTimeValidHourInvalidMinute() {
        #expect(throws: DomainError.invalidTime) {
            try MedTime(hour: 0, minute: 60)
        }
    }
    
    @Test func medTimeValidHourValidMinute() throws {
        let medtime = try MedTime(hour: 23, minute: 59)
        #expect(medtime.hour == 23)
        #expect(medtime.minute == 59)
    }
    
    @Test func medTimeZeroTest() throws {
        let medtime = try MedTime(hour: 0, minute: 0)
        #expect(medtime.hour == 0)
        #expect(medtime.minute == 0)
    }
    
    @Test func medTimeComparableOrdering() throws {
        let medtime1 = try MedTime(hour: 8, minute: 30)
        let medtime2 = try MedTime(hour: 20, minute: 0)
        #expect(medtime1 < medtime2)
    }
}
