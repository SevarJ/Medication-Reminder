//
//  MockNotificationAuthorizer.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Domain

public actor MockNotificationAuthorizer: NotificationAuthorizing {
    public private(set) var requestCount = 0

    private var currentAccess: NotificationAccess
    private let grantsOnRequest: Bool

    public init(access: NotificationAccess = .authorized, grantsOnRequest: Bool = true) {
        self.currentAccess = access
        self.grantsOnRequest = grantsOnRequest
    }

    public func setAccess(_ access: NotificationAccess) {
        currentAccess = access
    }

    public func requestAuthorization() async throws -> Bool {
        requestCount += 1

        if currentAccess == .notDetermined {
            currentAccess = grantsOnRequest ? .authorized : .denied
        }

        return currentAccess == .authorized
    }

    public func access() async -> NotificationAccess {
        currentAccess
    }
}
