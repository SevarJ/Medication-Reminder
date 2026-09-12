//
//  LocalNotificationAuthorizer.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import UserNotifications

struct LocalNotificationAuthorizer: NotificationAuthorizing {
    private let center: any UserNotificationCenter
    
    init(center: any UserNotificationCenter) {
        self.center = center
    }
    
    func requestAuthorization() async throws -> Bool {
        switch await center.authorizationStatus() {
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        default:
            return await isAuthorized()
        }
    }
    
    func isAuthorized() async -> Bool {
        switch await center.authorizationStatus() {
        case .provisional, .authorized:
            return true
        default:
            return false
        }
    }
}
