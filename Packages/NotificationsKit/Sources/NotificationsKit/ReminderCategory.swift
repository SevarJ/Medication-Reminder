//
//  ReminderCategory.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.09.26.
//

import UserNotifications

public enum ReminderCategory {
    public static let identifier = "medication.reminder"
    
    public static func register(on center: UNUserNotificationCenter = .current()) {
        center.setNotificationCategories([category])
    }
    
    static let takenActionIdentifier = "medication.reminder.taken"
    static let skippedActionIdentifier = "medication.reminder.skipped"
    static let snoozeActionIdentifier = "medication.reminder.snooze"
    
    private static var category: UNNotificationCategory {
        UNNotificationCategory(
            identifier: identifier,
            actions: [
                UNNotificationAction(identifier: takenActionIdentifier, title: L10n.Action.taken, options: []),
                UNNotificationAction(identifier: skippedActionIdentifier, title: L10n.Action.skip, options: []),
                UNNotificationAction(identifier: snoozeActionIdentifier, title: L10n.Action.snooze, options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
    }
}
