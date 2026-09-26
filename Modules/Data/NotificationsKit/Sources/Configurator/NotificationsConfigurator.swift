//
//  NotificationsConfigurator.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 26.09.26.
//

import DependencyInjection
import Domain

public enum NotificationsConfigurator {
    public static func setup(in container: DependencyContainer = .shared) {
        container.registerSingleton((any ReminderScheduling).self) { NotificationsFactory.makeScheduler() }
        container.registerSingleton((any NotificationAuthorizing).self) { NotificationsFactory.makeAuthorizer() }
    }
}
