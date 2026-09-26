//
//  AppComposition.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppPreferences
import DIContainer
import AppLocalization
import AppPreferences
import DIContainer
import Dashboard
import Domain
import Foundation
import Onboarding
import Settings

enum AppComposition {
    static func makeNotificationCoordinator(
        router: ReminderRouter,
        container: DependencyContainer = DependencyContainer()
    ) -> ReminderNotificationCoordinator {
        let services = Services(container: container)
        
        return ReminderNotificationCoordinator(
            recordDose: services.recordDoseForMedication,
            snoozeReminder: services.snoozeReminder,
            router: router
        )
    }
    
    static func makeDashboardDependencies(container: DependencyContainer = DependencyContainer()) -> DashboardDependencies {
        let services = Services(container: container)
        
        return DashboardDependencies(
            medications: services.medications,
            saveMedication: services.saveMedication,
            deleteMedication: services.deleteMedication,
            toggleMedicationActive: services.toggleMedicationActive,
            syncReminder: services.syncReminder,
            loadDoseHistory: services.loadDoseHistory,
            recordDose: services.recordDose,
            loadScheduledDose: services.loadScheduledDose,
            snoozeReminder: services.snoozeReminder,
            authorizer: services.authorizer
        )
    }
    
    static func makeSettingsDependencies(container: DependencyContainer = DependencyContainer()) -> SettingsDependencies {
        let services = Services(container: container)
        
        return SettingsDependencies(
            languageStore: services.languageStore,
            syncReminder: services.syncReminder,
            authorizer: services.authorizer,
            appVersion: appVersion
        )
    }
    
    static func makeOnboardingDependencies(container: DependencyContainer = DependencyContainer()) -> OnboardingDependencies {
        let services = Services(container: container)
        
        return OnboardingDependencies(
            authorizer: services.authorizer,
            syncReminder: services.syncReminder,
            preferences: AppPreferences()
        )
    }
    
    private static var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        let build = info?["CFBundleVersion"] as? String ?? ""
        
        return "\(version) (\(build))"
    }
}

private struct Services {
    let medications: any MedicationRepository
    let doseLogs: any DoseLogRepository
    let scheduler: any ReminderScheduling
    let authorizer: any NotificationAuthorizing
    let languageStore: any LanguagePreferenceStoring
    
    init(container: DependencyContainer) {
        medications = container.resolve(MedicationRepositoryKey.self)
        doseLogs = container.resolve(DoseLogRepositoryKey.self)
        scheduler = container.resolve(ReminderSchedulerKey.self)
        authorizer = container.resolve(NotificationAuthorizerKey.self)
        languageStore = container.resolve(LanguageStoreKey.self)
    }
    
    var saveMedication: SaveMedicationUseCase {
        SaveMedicationUseCase(repository: medications, scheduler: scheduler)
    }
    
    var deleteMedication: DeleteMedicationUseCase {
        DeleteMedicationUseCase(
            repository: medications,
            scheduler: scheduler,
            doseLogRepository: doseLogs
        )
    }
    
    var toggleMedicationActive: ToggleMedicationActiveUseCase {
        ToggleMedicationActiveUseCase(saveMedication: saveMedication)
    }
    
    var syncReminder: SyncReminderUseCase {
        SyncReminderUseCase(repository: medications, scheduler: scheduler)
    }
    
    var loadScheduledDose: LoadScheduledDoseUseCase {
        LoadScheduledDoseUseCase(medicationRepository: medications, doseLogRepository: doseLogs)
    }
    
    var recordDose: RecordDoseUseCase {
        RecordDoseUseCase(doseLogRepository: doseLogs)
    }
    
    var loadDoseHistory: LoadDoseHistoryUseCase {
        LoadDoseHistoryUseCase(medicationRepository: medications, doseLogRepository: doseLogs)
    }
    
    var recordDoseForMedication: RecordDoseForMedicationUseCase {
        RecordDoseForMedicationUseCase(
            medicationRepository: medications,
            doseLogRepository: doseLogs,
            recordDose: recordDose
        )
    }
    
    var snoozeReminder: SnoozeReminderUseCase {
        SnoozeReminderUseCase(repository: medications, scheduler: scheduler)
    }
}
