//
//  ReminderCategory.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 24.09.26.
//

public import UserNotifications

public enum ReminderCategory {
    static let identifier = "medication.reminder"
    
    public static func register(
        snoozeMinutes: Int,
        on center: UNUserNotificationCenter = .current()
    ) {
        center.setNotificationCategories([category(snoozeMinutes: snoozeMinutes)])
    }
    
    static let takenActionIdentifier = "medication.reminder.taken"
    static let skippedActionIdentifier = "medication.reminder.skipped"
    static let snoozeActionIdentifier = "medication.reminder.snooze"
    
    private static func category(snoozeMinutes: Int) -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: identifier,
            actions: [
                UNNotificationAction(identifier: takenActionIdentifier, title: L10n.Action.taken, options: []),
                UNNotificationAction(identifier: skippedActionIdentifier, title: L10n.Action.skip, options: []),
                UNNotificationAction(identifier: snoozeActionIdentifier, title: L10n.Action.snooze(minutes: snoozeMinutes), options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
    }
}
