//
//  AppPreferencesTests.swift
//  AppPreferencesTests
//
//  Created by Sevar Jafarli on 26.09.26.
//

@testable import AppPreferences
import Foundation
import Testing

struct AppPreferencesTests {
    private let defaults: UserDefaults
    private let sut: AppPreferences

    init() throws {
        defaults = try #require(UserDefaults(suiteName: "AppPreferencesTests.\(UUID().uuidString)"))
        sut = AppPreferences(defaults: defaults)
    }

    @Test func snoozeMinutesIsEmptyUntilChosen() {
        #expect(sut.snoozeMinutes == nil)
    }

    @Test func readsChosenSnoozeMinutes() {
        defaults.set(15, forKey: PreferenceKey.snoozeMinutes)

        #expect(sut.snoozeMinutes == 15)
    }

    @Test func remembersThatNotificationPrimingWasShown() {
        #expect(!sut.hasShownNotificationPriming)

        sut.markNotificationPrimingShown()

        #expect(sut.hasShownNotificationPriming)
    }

    @Test func remembersThatIntroductionWasSeen() {
        #expect(!sut.hasSeenIntroduction)

        sut.markIntroductionSeen()

        #expect(sut.hasSeenIntroduction)
    }

    @Test func paywallIsOffUntilEnabled() {
        #expect(!sut.isPaywallEnabled)

        defaults.set(true, forKey: PreferenceKey.paywallEnabled)

        #expect(sut.isPaywallEnabled)
    }

    @Test func remembersThatPaywallWasShown() {
        #expect(!sut.hasShownPaywall)

        sut.markPaywallShown()

        #expect(sut.hasShownPaywall)
    }
}
