//
//  LowStockAlertLog.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Foundation

protocol LowStockAlertLog: Sendable {
    func alertDate(for medicationId: UUID) -> Date?
    func setAlertDate(_ date: Date?, for medicationId: UUID)
    func removeAll()
}

struct UserDefaultsLowStockAlertLog: LowStockAlertLog, @unchecked Sendable {
    static let key = "reminder.lowStockAlertDates"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func alertDate(for medicationId: UUID) -> Date? {
        dates[medicationId.uuidString]
    }

    func setAlertDate(_ date: Date?, for medicationId: UUID) {
        var dates = dates
        dates[medicationId.uuidString] = date
        defaults.set(dates, forKey: Self.key)
    }

    func removeAll() {
        defaults.removeObject(forKey: Self.key)
    }

    private var dates: [String: Date] {
        defaults.dictionary(forKey: Self.key) as? [String: Date] ?? [:]
    }
}
