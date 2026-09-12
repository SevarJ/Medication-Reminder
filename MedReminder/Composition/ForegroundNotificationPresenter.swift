//
//  ForegroundNotificationPresenter.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 12.09.26.
//

import UserNotifications

final class ForegroundNotificationPresenter: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
