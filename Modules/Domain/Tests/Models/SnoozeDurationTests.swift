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
    private let defaults: UserDefaults
    
    init() throws {
        defaults = try #require(UserDefaults(suiteName: "SnoozeDurationTests.\(UUID().uuidString)"))
    }
    
    @Test func defaultsToTenMinutes() {
        #expect(SnoozeDuration.stored(in: defaults) == .tenMinutes)
        #expect(SnoozeReminderUseCase.defaultDelay == 10 * 60)
    }
    
    @Test func readsChosenDuration() {
        defaults.set(15, forKey: SnoozeDuration.storageKey)
        
        #expect(SnoozeDuration.stored(in: defaults) == .fifteenMinutes)
        #expect(SnoozeDuration.stored(in: defaults).interval == 15 * 60)
    }
    
    @Test func fallsBackToDefaultForUnsupportedValue() {
        defaults.set(7, forKey: SnoozeDuration.storageKey)
        
        #expect(SnoozeDuration.stored(in: defaults) == .default)
    }
}
