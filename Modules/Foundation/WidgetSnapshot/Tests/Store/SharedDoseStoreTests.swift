//
//  SharedDoseStoreTests.swift
//  WidgetSnapshot
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Foundation
import Testing
@testable import WidgetSnapshot

struct SharedDoseStoreTests {
    private func makeSUT() throws -> SharedDoseStore {
        SharedDoseStore(defaults: try #require(UserDefaults(suiteName: UUID().uuidString)))
    }

    private func makeEntry(at date: Date) -> UpcomingDoseEntry {
        UpcomingDoseEntry(
            medicationId: UUID(),
            name: "Aspirin",
            detail: "1 tablet",
            date: date,
            visibleUntil: date.addingTimeInterval(1800)
        )
    }

    @Test func startsEmpty() throws {
        #expect(try makeSUT().load() == .empty)
    }

    @Test func savesAndLoadsTheSnapshot() throws {
        let sut = try makeSUT()
        let snapshot = DoseSnapshot(doses: [makeEntry(at: Date(timeIntervalSince1970: 1000))], languageCode: "az")

        sut.save(snapshot)

        #expect(sut.load() == snapshot)
    }

    @Test func clearRemovesTheSnapshot() throws {
        let sut = try makeSUT()
        sut.save(DoseSnapshot(doses: [makeEntry(at: .now)], languageCode: nil))

        sut.clear()

        #expect(sut.load() == .empty)
    }

    @Test func hidesDosesWhoseTimeHasPassed() {
        let now = Date(timeIntervalSince1970: 10_000)
        let past = makeEntry(at: now.addingTimeInterval(-3600))
        let due = makeEntry(at: now.addingTimeInterval(-600))
        let snapshot = DoseSnapshot(doses: [past, due], languageCode: nil)

        #expect(snapshot.doses(visibleAt: now) == [due])
    }
}
