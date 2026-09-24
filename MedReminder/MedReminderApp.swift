//
//  MedReminderApp.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 01.08.26.
//

import MedicationFeature
import SwiftUI
import UserNotifications

@main
struct MedReminderApp: App {
    private let router: ReminderRouter
    private let notificationCoordinator: ReminderNotificationCoordinator
    
    init() {
        let router = ReminderRouter()
        
        self.router = router
        notificationCoordinator = AppComposition.makeNotificationCoordinator(router: router)
        notificationCoordinator.start()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(router: router)
        }
    }
}
