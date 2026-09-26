//
//  AppContainer.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppLocalization
import AppPreferences
import Dashboard
import Domain
import Foundation
import NotificationsKit
import Onboarding
import Persistence
import Settings

struct AppContainer {
    let dashboard: DashboardDependencies
    let settings: SettingsDependencies
    let onboarding: OnboardingDependencies
    let recordDoseForMedication: RecordDoseForMedicationUseCase
    let snoozeReminder: SnoozeReminderUseCase
    let preferences: AppPreferences

    init(bundle: Bundle = .main) {
        let store = Self.makeStore()
        let medications = store.medications
        let doseLogs = store.doseLogs
        let scheduler = NotificationsFactory.makeScheduler()
        let authorizer = NotificationsFactory.makeAuthorizer()
        let preferences = AppPreferences()

        let saveMedication = SaveMedicationUseCase(repository: medications, scheduler: scheduler)
        let syncReminder = SyncReminderUseCase(repository: medications, scheduler: scheduler)
        let recordDose = RecordDoseUseCase(doseLogRepository: doseLogs)
        let snoozeReminder = SnoozeReminderUseCase(repository: medications, scheduler: scheduler)

        dashboard = DashboardDependencies(
            medications: medications,
            saveMedication: saveMedication,
            deleteMedication: DeleteMedicationUseCase(
                repository: medications,
                scheduler: scheduler,
                doseLogRepository: doseLogs
            ),
            toggleMedicationActive: ToggleMedicationActiveUseCase(saveMedication: saveMedication),
            syncReminder: syncReminder,
            loadDoseHistory: LoadDoseHistoryUseCase(medicationRepository: medications, doseLogRepository: doseLogs),
            recordDose: recordDose,
            loadScheduledDose: LoadScheduledDoseUseCase(medicationRepository: medications, doseLogRepository: doseLogs),
            snoozeReminder: snoozeReminder,
            authorizer: authorizer
        )

        settings = SettingsDependencies(
            languageStore: UserDefaultsLanguageStore(),
            syncReminder: syncReminder,
            authorizer: authorizer,
            appVersion: Self.appVersion(in: bundle)
        )

        onboarding = OnboardingDependencies(
            authorizer: authorizer,
            syncReminder: syncReminder,
            preferences: preferences
        )

        recordDoseForMedication = RecordDoseForMedicationUseCase(
            medicationRepository: medications,
            doseLogRepository: doseLogs,
            recordDose: recordDose
        )
        self.snoozeReminder = snoozeReminder
        self.preferences = preferences
    }

    private static func makeStore() -> PersistenceStore {
        do {
            return try PersistenceFactory.makeStore()
        }
        catch {
            return try! PersistenceFactory.makeStore(inMemory: true)
        }
    }

    private static func appVersion(in bundle: Bundle) -> String {
        let info = bundle.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        let build = info?["CFBundleVersion"] as? String ?? ""

        return "\(version) (\(build))"
    }
}
