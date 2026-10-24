//
//  MockLowStockAlertLog.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Foundation
@testable import NotificationsKit

final class MockLowStockAlertLog: LowStockAlertLog, @unchecked Sendable {
    private(set) var dates: [UUID: Date] = [:]

    func alertDate(for medicationId: UUID) -> Date? {
        dates[medicationId]
    }

    func setAlertDate(_ date: Date?, for medicationId: UUID) {
        dates[medicationId] = date
    }

    func removeAll() {
        dates.removeAll()
    }
}
