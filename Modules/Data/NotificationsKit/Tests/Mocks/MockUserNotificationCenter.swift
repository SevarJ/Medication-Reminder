//
//  MockUserNotificationCenter.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

@testable import NotificationsKit
import UserNotifications

actor MockUserNotificationCenter: UserNotificationCenter {
    private(set) var added: [ReminderRequest] = []
    private(set) var removedIdentifiers: [String] = []
    private(set) var requestedOptions: UNAuthorizationOptions?
    
    private var status: UNAuthorizationStatus
    private let authorizationResult: Bool
    
    init(
        status: UNAuthorizationStatus = .authorized,
        authorizationResult: Bool = true
    ) {
        self.status = status
        self.authorizationResult = authorizationResult
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestedOptions = options
        status = authorizationResult ? .authorized : .denied
        return authorizationResult
    }
    
    func authorizationStatus() async -> UNAuthorizationStatus {
        status
    }
    
    func add(_ reminder: ReminderRequest) async throws {
        added.append(reminder)
    }
    
    func pendingIdentifiers() async -> [String] {
        added.map { $0.identifier }
    }
    
    func removePending(identifiers: [String]) async {
        removedIdentifiers.append(contentsOf: identifiers)
        added.removeAll { identifiers.contains($0.identifier) }
    }
}
