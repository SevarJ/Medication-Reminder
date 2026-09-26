//
//  AppComposition.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppPreferences
import DIContainer
import AppLocalization
import Domain
import Foundation
import MedicationFeature

enum AppComposition {
    @MainActor
    static func makeListViewModel(container: DependencyContainer = DependencyContainer()) -> MedicationListViewModel {
        let services = Services(container: container)
        
        return MedicationListViewModel(
            repository: services.medications,
            saveMedication: services.saveMedication,
            deleteMedication: services.deleteMedication,
            toggleMedicationActive: services.toggleMedicationActive,
            syncReminder: services.syncReminder,
            authorizer: services.authorizer
        )
    }
    
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
    
    @MainActor
    static func makeDoseReminderViewModel(
        medicationId: UUID,
        scheduledDate: Date,
        container: DependencyContainer = DependencyContainer()
    ) -> DoseReminderViewModel {
        let services = Services(container: container)
        
        return DoseReminderViewModel(
            medicationId: medicationId,
            scheduledDate: scheduledDate,
            loadDose: services.loadScheduledDose,
            recordDose: services.recordDose,
            snoozeReminder: services.snoozeReminder,
            snoozeDelay: SnoozeDuration(minutes: AppPreferences().snoozeMinutes).interval
        )
    }
    
    @MainActor
    static func makeNotificationPrimingModel(
        container: DependencyContainer = DependencyContainer()
    ) -> NotificationPrimingModel {
        let services = Services(container: container)
        
        return NotificationPrimingModel(
            authorizer: services.authorizer,
            syncReminder: services.syncReminder
        )
    }
    
    @MainActor
    static func makeTodayViewModel(container: DependencyContainer = DependencyContainer()) -> TodayViewModel {
        let services = Services(container: container)
        
        return TodayViewModel(
            loadHistory: services.loadDoseHistory,
            recordDose: services.recordDose,
            saveMedication: services.saveMedication
        )
    }
    
    @MainActor
    static func makeSettingsViewModel(container: DependencyContainer = DependencyContainer()) -> SettingsViewModel {
        let services = Services(container: container)
        
        return SettingsViewModel(
            languageStore: services.languageStore,
            syncReminder: services.syncReminder,
            authorizer: services.authorizer,
            appVersion: appVersion
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
