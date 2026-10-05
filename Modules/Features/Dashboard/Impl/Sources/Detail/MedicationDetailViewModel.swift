//
//  MedicationDetailViewModel.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import AppFormatters
import Domain
import Foundation
import Observation

@MainActor
@Observable
final class MedicationDetailViewModel {
    private(set) var medication: Medication
    private(set) var history: [DoseDaySummary] = []
    var errorMessage: String?
    
    private let repository: any MedicationRepository
    private let loadHistory: LoadMedicationHistoryUseCase
    private let saveMedication: SaveMedicationUseCase
    private let deleteMedication: DeleteMedicationUseCase
    private let toggleMedicationActive: ToggleMedicationActiveUseCase
    private let currentDate: @Sendable () -> Date
    
    init(
        medication: Medication,
        repository: any MedicationRepository,
        loadHistory: LoadMedicationHistoryUseCase,
        saveMedication: SaveMedicationUseCase,
        deleteMedication: DeleteMedicationUseCase,
        toggleMedicationActive: ToggleMedicationActiveUseCase,
        currentDate: @escaping @Sendable () -> Date = { .now }
    ) {
        self.medication = medication
        self.repository = repository
        self.loadHistory = loadHistory
        self.saveMedication = saveMedication
        self.deleteMedication = deleteMedication
        self.toggleMedicationActive = toggleMedicationActive
        self.currentDate = currentDate
    }
    
    /// Every dose of the last week that has already come due, newest first.
    var dueDoses: [ScheduledDose] {
        let now = currentDate()
        
        return history
            .flatMap { $0.doses.reversed() }
            .filter { $0.scheduledDate <= now }
    }
    
    var takenCount: Int {
        count(of: .taken)
    }
    
    var skippedCount: Int {
        count(of: .skipped)
    }
    
    var missedCount: Int {
        count(of: .missed)
    }
    
    var adherence: Double {
        let doses = dueDoses
        
        guard !doses.isEmpty else { return 0 }
        
        return Double(takenCount) / Double(doses.count)
    }
    
    func state(of dose: ScheduledDose) -> DoseState {
        dose.state(at: currentDate())
    }
    
    func load() async {
        do {
            medication = try await repository.fetch(id: medication.id)
            history = try await loadHistory.execute(medication, endingOn: currentDate())
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
    
    func toggle() async {
        do {
            medication = try await toggleMedicationActive.execute(medication)
        }
        catch is ReminderError {
            await load()
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
    
    func delete() async -> Bool {
        do {
            try await deleteMedication.execute(id: medication.id)
            return true
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
            return false
        }
    }
    
    func makeEditorViewModel() -> MedicationEditorViewModel {
        MedicationEditorViewModel(medication: medication, saveMedication: saveMedication)
    }
    
    private func count(of state: DoseState) -> Int {
        dueDoses.count { self.state(of: $0) == state }
    }
}
