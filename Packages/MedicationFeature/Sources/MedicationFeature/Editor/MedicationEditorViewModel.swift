//
//  MedicationEditorViewModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class MedicationEditorViewModel: Identifiable {
    public let id = UUID()
    
    var name: String
    var amountText: String
    var unit: DosageUnit
    var times: [Date]
    var isActive: Bool
    var errorMessage: String?
    private(set) var isSaving = false
    
    let medication: Medication?
    private let saveMedication: SaveMedicationUseCase
    
    init(medication: Medication?, saveMedication: SaveMedicationUseCase) {
        self.medication = medication
        self.saveMedication = saveMedication
        self.name = medication?.name ?? ""
        self.amountText = medication.map { Self.text(for: $0.dosage.amount) } ?? "1"
        self.unit = medication?.dosage.unit ?? .tablet
        self.times = medication?.times.map { $0.date } ?? [.at(hour: 9, minute: 0)]
        self.isActive = medication?.isActive ?? true
    }
    
    var isEditing: Bool {
        medication != nil
    }
    
    var title: String {
        isEditing ? "Edit Medication" : "New Medication"
    }
    
    func addTime() {
        times.append(.at(hour: 12, minute: 0))
    }
    
    func removeTime(at index: Int) {
        guard times.indices.contains(index), times.count > 1 else { return }
        times.remove(at: index)
    }
    
    func save() async -> Bool {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              amount > 0
        else {
            errorMessage = "Enter a dosage amount greater than zero."
            return false
        }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            let medTimes = try times.map { date -> MedTime in
                let value = date.hourAndMinute
                return try MedTime(hour: value.hour, minute: value.minute)
            }
            
            let updated = Medication(
                id: medication?.id ?? UUID(),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                dosage: Dosage(amount: amount, unit: unit),
                times: medTimes.sorted(),
                isActive: isActive,
                createdDate: medication?.createdDate ?? .now
            )
            
            try await saveMedication.execute(updated)
            
            return true
        }
        catch is ReminderError {
            return true
        }
        catch {
            errorMessage = message(for: error)
            return false
        }
    }
    
    private static func text(for amount: Double) -> String {
        amount.rounded() == amount
            ? String(Int(amount))
            : String(amount)
    }
}
