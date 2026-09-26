//
//  MedReminderApp.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 01.08.26.
//

import AppPreferences
import DashboardImpl
import DependencyInjection
import Domain
import NotificationsKit
import OnboardingImpl
import Persistence
import SettingsImpl
import SwiftUI

@main
struct MedReminderApp: App {
    private let router: ReminderRouter
    private let notificationCoordinator: ReminderNotificationCoordinator
    
    init() {
        PersistenceConfigurator.setup()
        NotificationsConfigurator.setup()
        
        let router = ReminderRouter()
        let medications: any MedicationRepository = resolve()
        let doseLogs: any DoseLogRepository = resolve()
        let scheduler: any ReminderScheduling = resolve()
        
        self.router = router
        notificationCoordinator = ReminderNotificationCoordinator(
            recordDose: RecordDoseForMedicationUseCase(
                medicationRepository: medications,
                doseLogRepository: doseLogs,
                recordDose: RecordDoseUseCase(doseLogRepository: doseLogs)
            ),
            snoozeReminder: SnoozeReminderUseCase(repository: medications, scheduler: scheduler),
            preferences: AppPreferences(),
            router: router
        )
        notificationCoordinator.start()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(
                router: router,
                dashboard: DashboardModuleConfigurator.makeModule(),
                settings: SettingsModuleConfigurator.makeModule(),
                onboarding: OnboardingModuleConfigurator.makeModule()
            )
        }
    }
}
