//
//  MedicationListViewModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class MedicationListViewModel {
     
    public private(set) var notificationsUnavailable = false
    public var errorMessage: String?
    
    private let repository: any MedicationRepository
    private let saveMedication: SaveMedicationUseCase
    private let deleteMedication: DeleteMedicationUseCase
    private let toggleMedicationActive: ToggleMedicationActiveUseCase
    private let authorizer: any NotificationAuthorizing
    
    private(set) var state: MedicationListState = .loading
    
    public init(
        repository: any MedicationRepository,
        saveMedication: SaveMedicationUseCase,
        deleteMedication: DeleteMedicationUseCase,
        toggleMedicationActive: ToggleMedicationActiveUseCase,
        authorizer: any NotificationAuthorizing
    ) {
        self.repository = repository
        self.saveMedication = saveMedication
        self.deleteMedication = deleteMedication
        self.toggleMedicationActive = toggleMedicationActive
        self.authorizer = authorizer
    }
    
    public func start() async {
        await requestNotificationAccess()
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
            state = .failure(message: message(for: error))
        }
    }
    
    func toggle(_ medication: Medication) async {
        do {
            _ = try await toggleMedicationActive.execute(medication)
        }
        catch is ReminderError {
            notificationsUnavailable = true
        }
        catch {
            errorMessage = message(for: error)
        }
        
        await load()
    }
    
    func delete(_ medication: Medication) async {
        do {
            try await deleteMedication.execute(id: medication.id)
        }
        catch {
            errorMessage = message(for: error)
        }
        
        await load()
    }
    
    func makeEditorViewModel(for medication: Medication?) -> MedicationEditorViewModel {
        MedicationEditorViewModel(
            medication: medication,
            saveMedication: saveMedication
        )
    }
    
    private func requestNotificationAccess() async {
        do {
            notificationsUnavailable = try await authorizer.requestAuthorization() == false
        }
        catch {
            notificationsUnavailable = true
        }
    }
}
