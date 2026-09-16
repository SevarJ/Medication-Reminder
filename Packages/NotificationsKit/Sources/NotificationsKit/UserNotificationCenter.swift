//
//  UserNotificationCenter.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 09.09.26.
//

import UserNotifications

protocol UserNotificationCenter: Sendable {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    
    func authorizationStatus() async -> UNAuthorizationStatus
    
    func add(_ reminder: ReminderRequest) async throws
    
    func pendingIdentifiers() async -> [String]
    
    func removePending(identifiers: [String]) async
}

final class SystemNotificationCenter: UserNotificationCenter, @unchecked Sendable {
    private let center: UNUserNotificationCenter
    
    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await center.requestAuthorization(options: options)
    }
    
    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }
    
    func add(_ reminder: ReminderRequest) async throws {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.threadIdentifier = reminder.medicationId.uuidString
        content.userInfo = [ReminderUserInfoKey.medicationId: reminder.medicationId.uuidString]
        
        var components = DateComponents()
        components.hour = reminder.hour
        components.minute = reminder.minute
        components.weekday = reminder.weekday
        
        let request = UNNotificationRequest(
            identifier: reminder.identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )
        
        try await center.add(request)
    }
    
    func pendingIdentifiers() async -> [String] {
        await center.pendingNotificationRequests().map { $0.identifier }
    }
    
    func removePending(identifiers: [String]) async {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

public enum ReminderUserInfoKey {
    public static let medicationId = "medicationId"
}
