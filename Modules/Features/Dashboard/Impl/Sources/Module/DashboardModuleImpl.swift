//
//  DashboardModuleImpl.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppPreferences
import Dashboard
import DependencyInjection
import Domain
import Foundation
import SwiftUI

struct DashboardModuleImpl: DashboardModule {
    private let medications: any MedicationRepository
    private let doseLogs: any DoseLogRepository
    private let scheduler: any ReminderScheduling
    private let authorizer: any NotificationAuthorizing
    private let preferences: AppPreferences

    init(
        medications: any MedicationRepository = resolve(),
        doseLogs: any DoseLogRepository = resolve(),
        scheduler: any ReminderScheduling = resolve(),
        authorizer: any NotificationAuthorizing = resolve(),
        preferences: AppPreferences = AppPreferences()
    ) {
        self.medications = medications
        self.doseLogs = doseLogs
        self.scheduler = scheduler
        self.authorizer = authorizer
        self.preferences = preferences
    }

    @MainActor
    @ViewBuilder
    func makeScreen(_ route: DashboardRoute) -> some View {
        switch route {
        case .today(let reloadToken):
            makeTodayView(reloadToken: reloadToken)
        case .medications:
            makeMedicationsView()
        case .doseReminder(let medicationId, let scheduledDate):
            makeDoseReminderView(medicationId: medicationId, scheduledDate: scheduledDate)
        }
    }

    @MainActor
    private func makeTodayView(reloadToken: Int) -> some View {
        TodayView(
            viewModel: TodayViewModel(
                loadHistory: LoadDoseHistoryUseCase(medicationRepository: medications, doseLogRepository: doseLogs),
                recordDose: recordDose,
                saveMedication: saveMedication
            ),
            reloadToken: reloadToken
        )
    }

    @MainActor
    private func makeMedicationsView() -> some View {
        MedicationListView(
            viewModel: MedicationListViewModel(
                repository: medications,
                saveMedication: saveMedication,
                deleteMedication: DeleteMedicationUseCase(
                    repository: medications,
                    scheduler: scheduler,
                    doseLogRepository: doseLogs
                ),
                toggleMedicationActive: ToggleMedicationActiveUseCase(saveMedication: saveMedication),
                syncReminder: SyncReminderUseCase(repository: medications, scheduler: scheduler),
                authorizer: authorizer
            )
        )
    }

    @MainActor
    private func makeDoseReminderView(medicationId: UUID, scheduledDate: Date) -> some View {
        DoseReminderView(
            viewModel: DoseReminderViewModel(
                medicationId: medicationId,
                scheduledDate: scheduledDate,
                loadDose: LoadScheduledDoseUseCase(medicationRepository: medications, doseLogRepository: doseLogs),
                recordDose: recordDose,
                snoozeReminder: SnoozeReminderUseCase(repository: medications, scheduler: scheduler),
                snoozeDelay: SnoozeDuration(minutes: preferences.snoozeMinutes).interval
            )
        )
    }

    private var saveMedication: SaveMedicationUseCase {
        SaveMedicationUseCase(repository: medications, scheduler: scheduler)
    }

    private var recordDose: RecordDoseUseCase {
        RecordDoseUseCase(doseLogRepository: doseLogs)
    }
}
