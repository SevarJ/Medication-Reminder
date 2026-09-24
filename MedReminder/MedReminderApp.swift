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
    private let notificationPresenter = ForegroundNotificationPresenter()
    
    init() {
        UNUserNotificationCenter.current().delegate = notificationPresenter
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
