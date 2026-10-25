//
//  ReminderResponseParserTests.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation
import Testing
import UserNotifications
@testable import NotificationsKit

struct ReminderResponseParserTests {
    private let calendar = Calendar(identifier: .gregorian)
    
    private func userInfo(medicationId: UUID, hour: Int? = 9, minute: Int? = 0) -> [AnyHashable: Any] {
        var info: [AnyHashable: Any] = [ReminderUserInfoKey.medicationId: medicationId.uuidString]
        
        info[ReminderUserInfoKey.hour] = hour
        info[ReminderUserInfoKey.minute] = minute
        
        return info
    }
    
    private func deliveredAt(hour: Int, minute: Int) throws -> Date {
        try #require(
            calendar.date(from: DateComponents(year: 2026, month: 9, day: 24, hour: hour, minute: minute))
        )
    }
    
    @Test func mapsActionIdentifiersToActions() async throws {
        let medicationId = UUID()
        let delivered = try deliveredAt(hour: 9, minute: 0)
        
        let actions = [
            ReminderCategory.takenActionIdentifier,
            ReminderCategory.skippedActionIdentifier,
            ReminderCategory.snoozeActionIdentifier,
            UNNotificationDefaultActionIdentifier
        ].compactMap {
            ReminderResponseParser.parse(
                userInfo: userInfo(medicationId: medicationId),
                actionIdentifier: $0,
                deliveredAt: delivered,
                calendar: calendar
            )?.action
        }
        
        #expect(actions == [.taken, .skipped, .snooze, .opened])
    }
    
    @Test func ignoresDismissAction() async throws {
        let response = ReminderResponseParser.parse(
            userInfo: userInfo(medicationId: UUID()),
            actionIdentifier: UNNotificationDismissActionIdentifier,
            deliveredAt: try deliveredAt(hour: 9, minute: 0),
            calendar: calendar
        )
        
        #expect(response == nil)
    }
    
    @Test func ignoresPayloadWithoutMedication() async throws {
        let response = ReminderResponseParser.parse(
            userInfo: [:],
            actionIdentifier: ReminderCategory.takenActionIdentifier,
            deliveredAt: try deliveredAt(hour: 9, minute: 0),
            calendar: calendar
        )
        
        #expect(response == nil)
    }
    
    @Test func usesScheduledTimeRatherThanDeliveryTime() async throws {
        let medicationId = UUID()
        
        let response = try #require(
            ReminderResponseParser.parse(
                userInfo: userInfo(medicationId: medicationId, hour: 9, minute: 0),
                actionIdentifier: ReminderCategory.takenActionIdentifier,
                deliveredAt: try deliveredAt(hour: 9, minute: 43),
                calendar: calendar
            )
        )
        
        #expect(response.medicationId == medicationId)
        #expect(response.scheduledDate == (try deliveredAt(hour: 9, minute: 0)))
    }
    
    @Test func fallsBackToDeliveryTimeWhenScheduleIsMissing() async throws {
        let delivered = try deliveredAt(hour: 21, minute: 30)
        
        let response = try #require(
            ReminderResponseParser.parse(
                userInfo: userInfo(medicationId: UUID(), hour: nil, minute: nil),
                actionIdentifier: ReminderCategory.takenActionIdentifier,
                deliveredAt: delivered,
                calendar: calendar
            )
        )
        
        #expect(response.scheduledDate == delivered)
    }
    
    @Test func followUpUsesTheDoseItRemindsOfEvenOnTheNextDay() async throws {
        let dose = try deliveredAt(hour: 23, minute: 50)
        var info = userInfo(medicationId: UUID(), hour: 0, minute: 20)
        
        info[ReminderUserInfoKey.scheduledDate] = dose.timeIntervalSince1970
        
        let response = try #require(
            ReminderResponseParser.parse(
                userInfo: info,
                actionIdentifier: ReminderCategory.takenActionIdentifier,
                deliveredAt: dose.addingTimeInterval(30 * 60),
                calendar: calendar
            )
        )
        
        #expect(response.scheduledDate == dose)
    }
    
    @Test func readsTheDoseOfAFollowUp() async throws {
        let medicationId = UUID()
        let dose = try deliveredAt(hour: 9, minute: 0)
        var info = userInfo(medicationId: medicationId)
        
        info[ReminderUserInfoKey.scheduledDate] = dose.timeIntervalSince1970
        
        let followUp = ReminderResponseParser.followUpDose(userInfo: info)
        
        #expect(followUp == FollowUpDose(medicationId: medicationId, scheduledDate: dose))
    }
    
    @Test func plainReminderIsNoFollowUp() async throws {
        #expect(ReminderResponseParser.followUpDose(userInfo: userInfo(medicationId: UUID())) == nil)
    }
}
