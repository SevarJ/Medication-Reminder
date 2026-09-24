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
    private let notificationCoordinator = AppComposition.makeNotificationCoordinator()
    
    init() {
        notificationCoordinator.start()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
