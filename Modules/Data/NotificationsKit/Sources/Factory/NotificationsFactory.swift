//
//  NotificationsFactory.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain

enum NotificationsFactory {
    static func makeScheduler() -> any ReminderScheduling {
        LocalNotificationScheduler(center: SystemNotificationCenter())
    }
    
    static func makeAuthorizer() -> any NotificationAuthorizing {
        LocalNotificationAuthorizer(center: SystemNotificationCenter())
    }
}
