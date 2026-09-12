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
        let repository = container.resolve(MedicationRepositoryKey.self)
        let scheduler = container.resolve(ReminderSchedulerKey.self)
        let authorizer = container.resolve(NotificationAuthorizerKey.self)
        
        let saveMedication = SaveMedicationUseCase(
            repository: repository,
            scheduler: scheduler
        )
        
        return MedicationListViewModel(
            repository: repository,
            saveMedication: saveMedication,
            deleteMedication: DeleteMedicationUseCase(
                repository: repository,
                scheduler: scheduler
            ),
            toggleMedicationActive: ToggleMedicationActiveUseCase(saveMedication: saveMedication),
            syncReminder: SyncReminderUseCase(
                repository: repository,
                scheduler: scheduler
            ),
            authorizer: authorizer
        )
    }
}
