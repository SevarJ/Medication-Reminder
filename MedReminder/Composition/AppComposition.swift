//
//  AppComposition.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 12.09.26.
//

import DIContainer
import Domain
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
        container: DependencyContainer = DependencyContainer()
    ) -> ReminderNotificationCoordinator {
        let services = Services(container: container)
        
        return ReminderNotificationCoordinator(
            recordDose: services.recordDoseForMedication,
            snoozeReminder: services.snoozeReminder
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
            loadDoses: services.loadDoses,
            recordDose: services.recordDose
        )
    }
    
    @MainActor
    static func makeHistoryViewModel(container: DependencyContainer = DependencyContainer()) -> HistoryViewModel {
        let services = Services(container: container)
        
        return HistoryViewModel(
            loadHistory: services.loadDoseHistory,
            recordDose: services.recordDose
        )
    }
}

private struct Services {
    let medications: any MedicationRepository
    let doseLogs: any DoseLogRepository
    let scheduler: any ReminderScheduling
    let authorizer: any NotificationAuthorizing
    
    init(container: DependencyContainer) {
        medications = container.resolve(MedicationRepositoryKey.self)
        doseLogs = container.resolve(DoseLogRepositoryKey.self)
        scheduler = container.resolve(ReminderSchedulerKey.self)
        authorizer = container.resolve(NotificationAuthorizerKey.self)
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
    
    var loadDoses: LoadDosesUseCase {
        LoadDosesUseCase(medicationRepository: medications, doseLogRepository: doseLogs)
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
