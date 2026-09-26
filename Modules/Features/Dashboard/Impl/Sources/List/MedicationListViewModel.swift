//
//  MedicationListViewModel.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppFormatters
import Domain
import Foundation
import Observation

@MainActor
@Observable
final class MedicationListViewModel {
    private(set) var notificationAccess: NotificationAccess?
    var errorMessage: String?
    
    private let repository: any MedicationRepository
    private let saveMedication: SaveMedicationUseCase
    private let deleteMedication: DeleteMedicationUseCase
    private let toggleMedicationActive: ToggleMedicationActiveUseCase
    private let syncReminder: SyncReminderUseCase
    private let authorizer: any NotificationAuthorizing
    
    private(set) var state: MedicationListState = .loading
    
    init(
        repository: any MedicationRepository,
        saveMedication: SaveMedicationUseCase,
        deleteMedication: DeleteMedicationUseCase,
        toggleMedicationActive: ToggleMedicationActiveUseCase,
        syncReminder: SyncReminderUseCase,
        authorizer: any NotificationAuthorizing
    ) {
        self.repository = repository
        self.saveMedication = saveMedication
        self.deleteMedication = deleteMedication
        self.toggleMedicationActive = toggleMedicationActive
        self.syncReminder = syncReminder
        self.authorizer = authorizer
    }
    
    var notificationsUnavailable: Bool {
        notificationAccess.map { $0 != .authorized } ?? false
    }
    
    func start() async {
        await apply(await authorizer.access(), forceSync: true)
        await load()
    }
    
    func load() async {
        switch state {
        case .loaded, .empty:
            break
        case .loading, .failure:
            state = .loading
        }
        
        do {
            let medications = try await repository
                .fetchAll()
                .sorted { $0.createdDate < $1.createdDate }
            
            state = medications.isEmpty ? .empty : .loaded(medications)
        }
        catch {
            state = .failure(message: ErrorFormatter.message(for: error))
        }
    }
    
    func toggle(_ medication: Medication) async {
        do {
            _ = try await toggleMedicationActive.execute(medication)
        }
        catch is ReminderError {
            notificationAccess = await authorizer.access()
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
        
        await load()
    }
    
    func delete(_ medication: Medication) async {
        do {
            try await deleteMedication.execute(id: medication.id)
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
        
        await load()
    }
    
    func makeEditorViewModel(for medication: Medication?) -> MedicationEditorViewModel {
        MedicationEditorViewModel(
            medication: medication,
            saveMedication: saveMedication
        )
    }
    
    func refreshNotificationAccess() async {
        await apply(await authorizer.access(), forceSync: false)
    }
    
    func enableNotifications() async {
        _ = try? await authorizer.requestAuthorization()
        
        await apply(await authorizer.access(), forceSync: true)
    }
    
    private func apply(_ access: NotificationAccess, forceSync: Bool) async {
        let wasUnavailable = notificationsUnavailable
        
        notificationAccess = access
        
        guard access == .authorized, forceSync || wasUnavailable else { return }
        
        do {
            try await syncReminder.execute()
        }
        catch is ReminderError {
            notificationAccess = await authorizer.access()
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
}
