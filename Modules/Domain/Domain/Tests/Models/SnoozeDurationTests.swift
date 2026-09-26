//
//  SnoozeDurationTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

@testable import Domain
import Foundation
import Testing

struct SnoozeDurationTests {
    @Test func defaultsToTenMinutes() {
        #expect(SnoozeDuration(minutes: nil) == .tenMinutes)
        #expect(SnoozeReminderUseCase.defaultDelay == 10 * 60)
    }
    
    @Test func readsChosenDuration() {
        #expect(SnoozeDuration(minutes: 15) == .fifteenMinutes)
        #expect(SnoozeDuration(minutes: 15).interval == 15 * 60)
    }
    
    @Test func fallsBackToDefaultForUnsupportedValue() {
        #expect(SnoozeDuration(minutes: 7) == .default)
    }
}
