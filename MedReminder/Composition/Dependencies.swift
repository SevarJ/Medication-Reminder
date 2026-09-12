//
//  Dependencies.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 12.09.26.
//

import DIContainer
import Domain
import NotificationsKit
import Persistence

enum MedicationRepositoryKey: DependencyKey {
    static let liveValue: any MedicationRepository = {
        do {
            return try PersistenceFactory.makeRepository()
        }
        catch {
            return try! PersistenceFactory.makeRepository(inMemory: true)
        }
    }()
}

enum ReminderSchedulerKey: DependencyKey {
    static let liveValue: any ReminderScheduling = NotificationsFactory.makeScheduler()
}

enum NotificationAuthorizerKey: DependencyKey {
    static let liveValue: any NotificationAuthorizing = NotificationsFactory.makeAuthorizer()
}
