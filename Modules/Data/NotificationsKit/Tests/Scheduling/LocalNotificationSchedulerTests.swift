//
//  LocalNotificationSchedulerTests.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import DomainTesting
import Foundation
import Testing
@testable import NotificationsKit

struct LocalNotificationSchedulerTests {
    @Test func schedulesOneReminderPerTime() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(times: [(9, 0), (21, 30)])
        
        try await sut.schedule(for: medication)
        
        let added = await center.added
        
        #expect(added.count == 2)
        #expect(added.compactMap { $0.hour } == [9, 21])
        #expect(added.compactMap { $0.minute } == [0, 30])
        #expect(added.allSatisfy { $0.title == medication.name })
        #expect(added.allSatisfy { $0.medicationId == medication.id })
    }
    
    @Test func reminderBodyNamesTheIntakeTags() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(intakeTags: [.custom("With water")])
        
        try await sut.schedule(for: medication)
        
        let added = await center.added
        
        #expect(added.allSatisfy { $0.body.hasSuffix(" · With water") })
    }
    
    @Test func reschedulingReplacesPreviousReminders() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(times: [(9, 0)])
        
        try await sut.schedule(for: medication)
        try await sut.schedule(for: medication)
        
        #expect(await center.added.count == 1)
    }
    
    @Test func cancelRemovesOnlyMatchingMedication() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let first = try makeMedication(times: [(9, 0)])
        let second = try makeMedication(times: [(12, 0)])
        
        try await sut.schedule(for: first)
        try await sut.schedule(for: second)
        try await sut.cancel(for: first.id)
        
        let remaining = await center.added
        
        #expect(remaining.count == 1)
        #expect(remaining.first?.medicationId == second.id)
    }
    
    @Test func cancelAllRemovesEveryPendingAndDeliveredReminder() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let first = try makeMedication(times: [(9, 0)])
        let second = try makeMedication(times: [(12, 0)])
        
        try await sut.schedule(for: first)
        try await sut.schedule(for: second)
        try await sut.snooze(first, until: .now.addingTimeInterval(600))
        try await sut.cancelAll()
        
        #expect(await center.added.isEmpty)
        #expect(await center.removeAllDeliveredCount == 1)
    }
    
    @Test func schedulingThrowsWhenAuthorizationDenied() async throws {
        let center = MockUserNotificationCenter(status: .denied)
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        
        await #expect(throws: ReminderError.authorizationDenied) {
            try await sut.schedule(for: try makeMedication())
        }
        
        #expect(await center.added.isEmpty)
    }
    
    @Test func schedulesOneReminderPerWeekdayAndTime() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(
            times: [(9, 0)],
            recurrence: .daysOfWeek([.monday, .friday])
        )
        
        try await sut.schedule(for: medication)
        
        let added = await center.added
        
        #expect(added.count == 2)
        #expect(added.compactMap { $0.weekday } == [2, 6])
        #expect(Set(added.map { $0.identifier }).count == 2)
    }
    
    @Test func dailyRemindersCarryNoWeekday() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        
        try await sut.schedule(for: try makeMedication())
        
        #expect(await center.added.allSatisfy { $0.weekday == nil })
    }
    
    @Test func doesNotScheduleBeforeStartDate() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(startDate: .now.addingTimeInterval(7 * 24 * 60 * 60))
        
        try await sut.schedule(for: medication)
        
        #expect(await center.added.isEmpty)
    }
    
    @Test func doesNotScheduleAfterEndDate() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(
            startDate: .now.addingTimeInterval(-14 * 24 * 60 * 60),
            endDate: .now.addingTimeInterval(-24 * 60 * 60)
        )
        
        try await sut.schedule(for: medication)
        
        #expect(await center.added.isEmpty)
    }
    
    @Test func dailyRemindersRepeat() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        
        try await sut.schedule(for: try makeMedication())
        
        #expect(await center.added.allSatisfy { $0.repeats })
    }
    
    @Test func snoozeAddsSingleReminderForGivenDate() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication()
        let until = try #require(
            Calendar.current.date(bySettingHour: 9, minute: 10, second: 0, of: .now)
        )
        
        try await sut.snooze(medication, until: until)
        
        let added = try #require(await center.added.first)
        
        #expect(await center.added.count == 1)
        #expect(added.repeats == false)
        #expect(added.hour == 9)
        #expect(added.minute == 10)
        #expect(added.identifier.hasPrefix(LocalNotificationScheduler.identifierPrefix(medicationId: medication.id)))
    }
    
    @Test func identifierIsNamespacedByMedication() async throws {
        let medicationId = UUID()
        let timeId = UUID()
        let identifier = LocalNotificationScheduler.identifier(
            medicationId: medicationId,
            timeId: timeId
        )
        
        #expect(identifier.hasPrefix(LocalNotificationScheduler.identifierPrefix(medicationId: medicationId)))
        #expect(identifier.hasSuffix(timeId.uuidString))
    }
    
    @Test func schedulingAddsALowStockAlertForTrackedStock() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(dosage: Dosage(amount: 1, unit: .tablet), stock: 30)
        
        try await sut.schedule(for: medication)
        
        let alert = try #require(await center.addedAlerts.first)
        
        #expect(await center.addedAlerts.count == 1)
        #expect(alert.identifier == LocalNotificationScheduler.lowStockIdentifier(medicationId: medication.id))
        #expect(alert.title == medication.name)
        #expect(alert.fireDate == medication.lowStockAlertDate())
    }
    
    @Test func schedulingWithoutStockAddsNoLowStockAlert() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        
        try await sut.schedule(for: try makeMedication())
        
        #expect(await center.addedAlerts.isEmpty)
    }
    
    @Test func lowStockAlertsOnlyOnceWhileTheStockStaysLow() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(dosage: Dosage(amount: 1, unit: .tablet), stock: 2)
        
        try await sut.scheduleLowStockAlert(for: medication)
        try await sut.scheduleLowStockAlert(for: medication.updating(stock: 1))
        
        let alerts = await center.addedAlerts
        
        #expect(alerts.count == 1)
        #expect(alerts.first?.fireDate == nil)
    }
    
    @Test func refillingLetsTheLowStockAlertComeAgain() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(dosage: Dosage(amount: 1, unit: .tablet), stock: 2)
        
        try await sut.scheduleLowStockAlert(for: medication)
        try await sut.scheduleLowStockAlert(for: medication.updating(stock: 30))
        try await sut.scheduleLowStockAlert(for: medication.updating(stock: 2))
        
        let alerts = await center.addedAlerts
        
        #expect(alerts.count == 2)
        #expect(alerts.allSatisfy { $0.fireDate == nil })
    }
    
    @Test func lowStockAlertComesEarlierWhenTheStockDropsFaster() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(dosage: Dosage(amount: 1, unit: .tablet), stock: 30)
        
        try await sut.scheduleLowStockAlert(for: medication)
        try await sut.scheduleLowStockAlert(for: medication.updating(stock: 3))
        
        let alerts = await center.addedAlerts
        
        #expect(alerts.count == 1)
        #expect(alerts.first?.fireDate == nil)
    }
    
    @Test func pausedMedicationGetsNoLowStockAlert() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        
        try await sut.scheduleLowStockAlert(for: try makeMedication(isActive: false, stock: 0))
        
        #expect(await center.addedAlerts.isEmpty)
    }
    
    @Test func cancelRemovesTheLowStockAlert() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(dosage: Dosage(amount: 1, unit: .tablet), stock: 30)
        
        try await sut.schedule(for: medication)
        try await sut.cancel(for: medication.id)
        
        #expect(await center.addedAlerts.isEmpty)
    }
    
    @Test func cancelAllForgetsPastLowStockAlerts() async throws {
        let center = MockUserNotificationCenter()
        let alertLog = MockLowStockAlertLog()
        let sut = LocalNotificationScheduler(center: center, alertLog: alertLog)
        
        try await sut.scheduleLowStockAlert(for: try makeMedication(stock: 0))
        try await sut.cancelAll()
        
        #expect(alertLog.dates.isEmpty)
    }
    
    @Test func followUpComesHalfAnHourAfterTheDose() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(intakeTags: [.custom("With water")])
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let dose = ScheduledDose(medication: medication, scheduledDate: now.addingTimeInterval(-10 * 60))
        
        try await sut.scheduleFollowUps(for: [dose], now: now)
        
        let added = try #require(await center.added.first)
        let fireDate = try #require(Calendar.current.date(from: added.components))
        
        #expect(await center.added.count == 1)
        #expect(added.repeats == false)
        #expect(fireDate == dose.scheduledDate.addingTimeInterval(LocalNotificationScheduler.followUpDelay))
        #expect(added.scheduledDate == dose.scheduledDate)
        #expect(added.title == medication.name)
        #expect(added.body.hasSuffix(" · With water"))
        #expect(added.identifier.hasPrefix(LocalNotificationScheduler.identifierPrefix(medicationId: medication.id)))
    }
    
    @Test func followUpsLeaveOutRecordedAndPastDoses() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let recorded = now.addingTimeInterval(60 * 60)
        let doses = [
            ScheduledDose(medication: medication, scheduledDate: now.addingTimeInterval(-40 * 60)),
            ScheduledDose(
                medication: medication,
                scheduledDate: recorded,
                log: DoseLog(medicationId: medication.id, scheduledDate: recorded, status: .taken, recordedAt: now)
            ),
            ScheduledDose(medication: try makeMedication(isActive: false), scheduledDate: recorded)
        ]
        
        try await sut.scheduleFollowUps(for: doses, now: now)
        
        #expect(await center.added.isEmpty)
    }
    
    @Test func schedulingFollowUpsReplacesTheEarlierOnes() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let first = ScheduledDose(medication: medication, scheduledDate: now)
        let second = ScheduledDose(medication: medication, scheduledDate: now.addingTimeInterval(60 * 60))
        
        try await sut.schedule(for: medication)
        try await sut.scheduleFollowUps(for: [first, second], now: now)
        try await sut.scheduleFollowUps(for: [second], now: now)
        
        let followUps = await center.added.filter { LocalNotificationScheduler.isFollowUpIdentifier($0.identifier) }
        
        #expect(followUps.map(\.scheduledDate) == [second.scheduledDate])
        #expect(await center.added.count == 2)
    }
    
    @Test func followUpsKeepRoomForTheRegularReminders() async throws {
        let center = MockUserNotificationCenter()
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let medication = try makeMedication(times: [(8, 0), (20, 0)])
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let doses = (1...100).map {
            ScheduledDose(medication: medication, scheduledDate: now.addingTimeInterval(Double($0) * 60 * 60))
        }
        
        try await sut.schedule(for: medication)
        try await sut.scheduleFollowUps(for: doses, now: now)
        
        let followUps = await center.added.filter { LocalNotificationScheduler.isFollowUpIdentifier($0.identifier) }
        
        #expect(followUps.count == LocalNotificationScheduler.pendingLimit - 2)
        #expect(followUps.first?.scheduledDate == doses.first?.scheduledDate)
    }
    
    @Test func followUpsNeedAuthorization() async throws {
        let center = MockUserNotificationCenter(status: .denied)
        let sut = LocalNotificationScheduler(center: center, alertLog: MockLowStockAlertLog())
        let dose = ScheduledDose(medication: try makeMedication(), scheduledDate: .now)
        
        await #expect(throws: ReminderError.authorizationDenied) {
            try await sut.scheduleFollowUps(for: [dose], now: .now)
        }
        
        #expect(await center.added.isEmpty)
    }
    
    @Test func followUpIdentifierIsNotARegularReminder() async throws {
        let medicationId = UUID()
        
        #expect(LocalNotificationScheduler.isFollowUpIdentifier(
            LocalNotificationScheduler.followUpIdentifier(medicationId: medicationId, scheduledDate: .now)
        ))
        #expect(!LocalNotificationScheduler.isFollowUpIdentifier(
            LocalNotificationScheduler.identifier(medicationId: medicationId, timeId: UUID())
        ))
        #expect(!LocalNotificationScheduler.isFollowUpIdentifier(
            LocalNotificationScheduler.lowStockIdentifier(medicationId: medicationId)
        ))
    }
}
