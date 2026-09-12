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
    @State private var listViewModel = AppComposition.makeListViewModel()
    
    private let notificationPresenter = ForegroundNotificationPresenter()
    
    init() {
        UNUserNotificationCenter.current().delegate = notificationPresenter
    }
    
    var body: some Scene {
        WindowGroup {
            MedicationListView(viewModel: listViewModel)
        }
    }
}
