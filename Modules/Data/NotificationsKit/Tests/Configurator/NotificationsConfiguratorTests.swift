//
//  NotificationsConfiguratorTests.swift
//  NotificationsKitTests
//
//  Created by Sevar Jafarli on 26.09.26.
//

import DependencyInjection
import Domain
@testable import NotificationsKit
import Testing

struct NotificationsConfiguratorTests {
    @Test func registersSchedulerAndAuthorizer() {
        let container = DependencyContainer()

        NotificationsConfigurator.setup(in: container)

        #expect(container.isRegistered((any ReminderScheduling).self))
        #expect(container.isRegistered((any NotificationAuthorizing).self))
    }
}
