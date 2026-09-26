//
//  AppPreferences.swift
//  AppPreferences
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Foundation

public struct AppPreferences: @unchecked Sendable {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var snoozeMinutes: Int? {
        defaults.object(forKey: PreferenceKey.snoozeMinutes) as? Int
    }

    public var hasShownNotificationPriming: Bool {
        defaults.bool(forKey: PreferenceKey.notificationPrimingShown)
    }

    public func markNotificationPrimingShown() {
        defaults.set(true, forKey: PreferenceKey.notificationPrimingShown)
    }
}
