//
//  DashboardDependencies.swift
//  Dashboard
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Domain

public struct DashboardDependencies {
    public let medications: any MedicationRepository
    public let saveMedication: SaveMedicationUseCase
    public let deleteMedication: DeleteMedicationUseCase
    public let toggleMedicationActive: ToggleMedicationActiveUseCase
    public let syncReminder: SyncReminderUseCase
    public let loadDoseHistory: LoadDoseHistoryUseCase
    public let recordDose: RecordDoseUseCase
    public let loadScheduledDose: LoadScheduledDoseUseCase
    public let snoozeReminder: SnoozeReminderUseCase
    public let authorizer: any NotificationAuthorizing

    public init(
        medications: any MedicationRepository,
        saveMedication: SaveMedicationUseCase,
        deleteMedication: DeleteMedicationUseCase,
        toggleMedicationActive: ToggleMedicationActiveUseCase,
        syncReminder: SyncReminderUseCase,
        loadDoseHistory: LoadDoseHistoryUseCase,
        recordDose: RecordDoseUseCase,
        loadScheduledDose: LoadScheduledDoseUseCase,
        snoozeReminder: SnoozeReminderUseCase,
        authorizer: any NotificationAuthorizing
    ) {
        self.medications = medications
        self.saveMedication = saveMedication
        self.deleteMedication = deleteMedication
        self.toggleMedicationActive = toggleMedicationActive
        self.syncReminder = syncReminder
        self.loadDoseHistory = loadDoseHistory
        self.recordDose = recordDose
        self.loadScheduledDose = loadScheduledDose
        self.snoozeReminder = snoozeReminder
        self.authorizer = authorizer
    }
}
