//
//  MedReminderApp.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI
import UserNotifications

@main
struct MedReminderApp: App {
    private let container: AppContainer
    private let router: ReminderRouter
    private let notificationCoordinator: ReminderNotificationCoordinator
    
    init() {
        let container = AppContainer()
        let router = ReminderRouter()
        
        self.container = container
        self.router = router
        notificationCoordinator = ReminderNotificationCoordinator(
            recordDose: container.recordDoseForMedication,
            snoozeReminder: container.snoozeReminder,
            preferences: container.preferences,
            router: router
        )
        notificationCoordinator.start()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(container: container, router: router)
        }
    }
}
