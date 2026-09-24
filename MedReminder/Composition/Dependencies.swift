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

enum PersistenceStoreKey: DependencyKey {
    static let liveValue: PersistenceStore = {
        do {
            return try PersistenceFactory.makeStore()
        }
        catch {
            return try! PersistenceFactory.makeStore(inMemory: true)
        }
    }()
}

enum MedicationRepositoryKey: DependencyKey {
    static let liveValue: any MedicationRepository = PersistenceStoreKey.liveValue.medications
}

enum DoseLogRepositoryKey: DependencyKey {
    static let liveValue: any DoseLogRepository = PersistenceStoreKey.liveValue.doseLogs
}

enum ReminderSchedulerKey: DependencyKey {
    static let liveValue: any ReminderScheduling = NotificationsFactory.makeScheduler()
}

enum NotificationAuthorizerKey: DependencyKey {
    static let liveValue: any NotificationAuthorizing = NotificationsFactory.makeAuthorizer()
}
