//
//  MedoraApp.swift
//  Medora
//
//  Created by Sevar Jafarli on 01.08.26.
//

import AccountImpl
import AppPreferences
import DashboardImpl
import DataSync
import DependencyInjection
import Domain
import FirebaseKit
import NotificationsKit
import OnboardingImpl
import Persistence
import SettingsImpl
import SwiftUI

@main
struct MedoraApp: App {
    private let router: ReminderRouter
    private let session: SessionStore
    private let notificationCoordinator: ReminderNotificationCoordinator
    
    init() {
        FirebaseConfigurator.setup()
        PersistenceConfigurator.setup()
        NotificationsConfigurator.setup()
        DataSyncConfigurator.setup()
        
        let router = ReminderRouter()
        let medications: any MedicationRepository = resolve()
        let doseLogs: any DoseLogRepository = resolve()
        let scheduler: any ReminderScheduling = resolve()
        
        self.router = router
        session = SessionStore(
            authenticator: resolve(),
            profiles: resolve(),
            refreshData: RefreshAccountDataUseCase(
                remoteMedications: resolve(),
                remoteDoseLogs: resolve(),
                medicationCache: resolve(),
                doseLogCache: resolve(),
                scheduler: scheduler
            ),
            clearLocalData: ClearLocalDataUseCase(
                medicationCache: resolve(),
                doseLogCache: resolve(),
                remoteOffline: resolve(),
                scheduler: scheduler
            )
        )
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
                session: session,
                account: AccountModuleConfigurator.makeModule(),
                dashboard: DashboardModuleConfigurator.makeModule(),
                settings: SettingsModuleConfigurator.makeModule(),
                onboarding: OnboardingModuleConfigurator.makeModule()
            )
        }
    }
}
