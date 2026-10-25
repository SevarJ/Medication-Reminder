//
//  PublishUpcomingDosesUseCaseTests.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

import DomainTesting
import Foundation
import Testing
@testable import Domain

struct PublishUpcomingDosesUseCaseTests {
    private let calendar = Calendar(identifier: .gregorian)

    private func date(day: Int, hour: Int = 0, minute: Int = 0) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour, minute: minute))
        )
    }

    private func makeSUT(
        medications: [Medication],
        logs: [DoseLog] = [],
        publisher: MockUpcomingDosePublisher,
        scheduler: MockReminderScheduler = MockReminderScheduler()
    ) -> PublishUpcomingDosesUseCase {
        PublishUpcomingDosesUseCase(
            medicationRepository: MockMedicationRepository(medications: medications),
            doseLogRepository: MockDoseLogRepository(logs: logs),
            publisher: publisher,
            scheduler: scheduler,
            calendar: calendar
        )
    }

    @Test func publishesTheComingDosesInOrder() async throws {
        let publisher = MockUpcomingDosePublisher()
        let medication = try makeMedication(times: [(9, 0), (21, 0)], startDate: try date(day: 1))
        let sut = makeSUT(medications: [medication], publisher: publisher)

        try await sut.execute(now: try date(day: 25, hour: 12))

        let doses = try #require(await publisher.published.first)

        #expect(doses.first?.scheduledDate == (try date(day: 25, hour: 21)))
        #expect(doses.dropFirst().first?.scheduledDate == (try date(day: 26, hour: 9)))
        #expect(doses.map(\.scheduledDate) == doses.map(\.scheduledDate).sorted())
    }

    @Test func keepsADoseThatIsOnlyJustDue() async throws {
        let publisher = MockUpcomingDosePublisher()
        let medication = try makeMedication(times: [(9, 0)], startDate: try date(day: 1))
        let sut = makeSUT(medications: [medication], publisher: publisher)

        try await sut.execute(now: try date(day: 25, hour: 9, minute: 20))

        let doses = try #require(await publisher.published.first)

        #expect(doses.first?.scheduledDate == (try date(day: 25, hour: 9)))
    }

    @Test func dropsDosesAlreadyRecorded() async throws {
        let publisher = MockUpcomingDosePublisher()
        let medication = try makeMedication(times: [(21, 0)], startDate: try date(day: 1))
        let log = DoseLog(
            medicationId: medication.id,
            scheduledDate: try date(day: 25, hour: 21),
            status: .taken,
            recordedAt: try date(day: 25, hour: 12)
        )
        let sut = makeSUT(medications: [medication], logs: [log], publisher: publisher)

        try await sut.execute(now: try date(day: 25, hour: 12))

        let doses = try #require(await publisher.published.first)

        #expect(doses.first?.scheduledDate == (try date(day: 26, hour: 21)))
    }

    @Test func leavesOutPausedMedications() async throws {
        let publisher = MockUpcomingDosePublisher()
        let medication = try makeMedication(startDate: try date(day: 1), isActive: false)
        let sut = makeSUT(medications: [medication], publisher: publisher)

        try await sut.execute(now: try date(day: 25, hour: 12))

        #expect(try #require(await publisher.published.first).isEmpty)
    }

    @Test func stopsAtTheLimit() async throws {
        let publisher = MockUpcomingDosePublisher()
        let times = (0..<12).map { ($0 * 2, 0) }
        let medication = try makeMedication(times: times, startDate: try date(day: 1))
        let sut = makeSUT(medications: [medication], publisher: publisher)

        try await sut.execute(now: try date(day: 25))

        #expect(try #require(await publisher.published.first).count == PublishUpcomingDosesUseCase.doseLimit)
    }

    @Test func schedulesFollowUpsForEveryDoseNotYetRecorded() async throws {
        let publisher = MockUpcomingDosePublisher()
        let scheduler = MockReminderScheduler()
        let times = (0..<12).map { ($0 * 2, 0) }
        let medication = try makeMedication(times: times, startDate: try date(day: 1))
        let log = DoseLog(
            medicationId: medication.id,
            scheduledDate: try date(day: 25, hour: 14),
            status: .skipped,
            recordedAt: try date(day: 25, hour: 12)
        )
        let sut = makeSUT(medications: [medication], logs: [log], publisher: publisher, scheduler: scheduler)

        try await sut.execute(now: try date(day: 25, hour: 12))

        let followUps = try #require(await scheduler.followUps.first)

        #expect(followUps.count > PublishUpcomingDosesUseCase.doseLimit)
        #expect(followUps.first?.scheduledDate == (try date(day: 25, hour: 12)))
        #expect(!followUps.contains { $0.scheduledDate == (try? date(day: 25, hour: 14)) })
    }

    @Test func publishesToTheWidgetEvenWhenFollowUpsCannotBeScheduled() async throws {
        let publisher = MockUpcomingDosePublisher()
        let scheduler = MockReminderScheduler(failsWithAuthorizationDenied: true)
        let medication = try makeMedication(times: [(21, 0)], startDate: try date(day: 1))
        let sut = makeSUT(medications: [medication], publisher: publisher, scheduler: scheduler)

        await #expect(throws: ReminderError.authorizationDenied) {
            try await sut.execute(now: try date(day: 25, hour: 12))
        }

        #expect(await publisher.published.count == 1)
    }

    @Test func clearRemovesThePublishedDoses() async throws {
        let publisher = MockUpcomingDosePublisher()
        let sut = makeSUT(medications: [], publisher: publisher)

        await sut.clear()

        #expect(await publisher.clearCount == 1)
    }
}
