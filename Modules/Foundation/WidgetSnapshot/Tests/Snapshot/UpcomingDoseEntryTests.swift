//
//  UpcomingDoseEntryTests.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation
import Testing
@testable import WidgetSnapshot

struct UpcomingDoseEntryTests {
    private let doseDate = Date(timeIntervalSince1970: 100_000)

    private var entry: UpcomingDoseEntry {
        UpcomingDoseEntry(
            medicationId: UUID(),
            name: "Aspirin",
            detail: "1 tablet",
            date: doseDate,
            visibleUntil: doseDate.addingTimeInterval(1800)
        )
    }

    @Test func isNotDueSoonHoursBefore() {
        #expect(entry.isDueSoon(at: doseDate.addingTimeInterval(-3 * 3600)) == false)
    }

    @Test func isDueSoonJustBefore() {
        #expect(entry.isDueSoon(at: doseDate.addingTimeInterval(-10 * 60)))
    }

    @Test func staysDueAfterItsTime() {
        #expect(entry.isDueSoon(at: doseDate.addingTimeInterval(10 * 60)))
    }
}
