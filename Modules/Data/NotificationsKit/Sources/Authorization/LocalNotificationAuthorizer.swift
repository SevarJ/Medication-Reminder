//
//  LocalNotificationAuthorizer.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
internal import UserNotifications

struct LocalNotificationAuthorizer: NotificationAuthorizing {
    private let center: any UserNotificationCenter
    
    init(center: any UserNotificationCenter) {
        self.center = center
    }
    
    func requestAuthorization() async throws -> Bool {
        switch await access() {
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        case .denied:
            return false
        case .authorized:
            return true
        }
    }
    
    func access() async -> NotificationAccess {
        switch await center.authorizationStatus() {
        case .notDetermined:
            .notDetermined
        case .authorized, .provisional, .ephemeral:
            .authorized
        case .denied:
            .denied
        @unknown default:
            .denied
        }
    }
}
