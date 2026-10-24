//
//  WidgetDosePublisherTests.swift
//  WidgetBridge
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppLocalization
import Domain
import DomainTesting
import Foundation
import os
import Testing
@testable import WidgetBridge
import WidgetSnapshot

struct WidgetDosePublisherTests {
    private final class ReloadCounter: Sendable {
        let count = OSAllocatedUnfairLock(initialState: 0)
    }

    private func makeSUT(store: SharedDoseStore, counter: ReloadCounter) -> WidgetDosePublisher {
        WidgetDosePublisher(
            store: store,
            language: { .azerbaijani },
            reloadWidgets: { counter.count.withLock { $0 += 1 } }
        )
    }

    private func makeStore() throws -> SharedDoseStore {
        SharedDoseStore(defaults: try #require(UserDefaults(suiteName: UUID().uuidString)))
    }

    @Test func savesEachDoseWithItsMedicationAndLanguage() async throws {
        let store = try makeStore()
        let counter = ReloadCounter()
        let sut = makeSUT(store: store, counter: counter)
        let medication = try makeMedication(name: "Aspirin", intakeTags: [.custom("With water")])
        let date = Date(timeIntervalSince1970: 50_000)

        await sut.publish([ScheduledDose(medication: medication, scheduledDate: date)])

        let snapshot = store.load()
        let entry = try #require(snapshot.doses.first)

        #expect(snapshot.languageCode == "az")
        #expect(entry.medicationId == medication.id)
        #expect(entry.name == "Aspirin")
        #expect(entry.detail.hasSuffix("With water"))
        #expect(entry.visibleUntil == date.addingTimeInterval(PublishUpcomingDosesUseCase.overdueWindow))
        #expect(counter.count.withLock { $0 } == 1)
    }

    @Test func doesNotReloadWhenNothingChanged() async throws {
        let store = try makeStore()
        let counter = ReloadCounter()
        let sut = makeSUT(store: store, counter: counter)
        let dose = ScheduledDose(medication: try makeMedication(), scheduledDate: Date(timeIntervalSince1970: 50_000))

        await sut.publish([dose])
        await sut.publish([dose])

        #expect(counter.count.withLock { $0 } == 1)
    }

    @Test func clearEmptiesTheStoreAndReloads() async throws {
        let store = try makeStore()
        let counter = ReloadCounter()
        let sut = makeSUT(store: store, counter: counter)
        await sut.publish([ScheduledDose(medication: try makeMedication(), scheduledDate: .now)])

        await sut.clear()

        #expect(store.load() == .empty)
        #expect(counter.count.withLock { $0 } == 2)
    }
}
