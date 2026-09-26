//
//  NotificationsFactory.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain

public enum NotificationsFactory {
    public static func makeScheduler() -> any ReminderScheduling {
        LocalNotificationScheduler(center: SystemNotificationCenter())
    }
    
    public static func makeAuthorizer() -> any NotificationAuthorizing {
        LocalNotificationAuthorizer(center: SystemNotificationCenter())
    }
}
