//
//  ReminderResponse.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation
public import UserNotifications

public struct ReminderResponse: Sendable, Equatable {
    public enum Action: Sendable, Equatable {
        case taken
        case skipped
        case snooze
        case opened
    }
    
    public let medicationId: UUID
    public let scheduledDate: Date
    public let action: Action
}

public enum ReminderResponseParser {
    public static func parse(
        _ response: UNNotificationResponse,
        calendar: Calendar = .current
    ) -> ReminderResponse? {
        parse(
            userInfo: response.notification.request.content.userInfo,
            actionIdentifier: response.actionIdentifier,
            deliveredAt: response.notification.date,
            calendar: calendar
        )
    }
    
    static func parse(
        userInfo: [AnyHashable: Any],
        actionIdentifier: String,
        deliveredAt: Date,
        calendar: Calendar = .current
    ) -> ReminderResponse? {
        guard let rawId = userInfo[ReminderUserInfoKey.medicationId] as? String,
              let medicationId = UUID(uuidString: rawId),
              let action = action(for: actionIdentifier)
        else {
            return nil
        }
        
        return ReminderResponse(
            medicationId: medicationId,
            scheduledDate: scheduledDate(from: userInfo, deliveredAt: deliveredAt, calendar: calendar),
            action: action
        )
    }
    
    private static func action(for identifier: String) -> ReminderResponse.Action? {
        switch identifier {
        case ReminderCategory.takenActionIdentifier: .taken
        case ReminderCategory.skippedActionIdentifier: .skipped
        case ReminderCategory.snoozeActionIdentifier: .snooze
        case UNNotificationDefaultActionIdentifier: .opened
        default: nil
        }
    }
    
    private static func scheduledDate(
        from userInfo: [AnyHashable: Any],
        deliveredAt: Date,
        calendar: Calendar
    ) -> Date {
        guard let hour = userInfo[ReminderUserInfoKey.hour] as? Int,
              let minute = userInfo[ReminderUserInfoKey.minute] as? Int,
              let scheduledDate = calendar.date(
                  bySettingHour: hour,
                  minute: minute,
                  second: 0,
                  of: deliveredAt
              )
        else {
            return deliveredAt
        }
        
        return scheduledDate
    }
}
