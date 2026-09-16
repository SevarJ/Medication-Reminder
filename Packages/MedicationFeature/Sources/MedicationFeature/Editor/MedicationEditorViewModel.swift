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
    var times: [MedTime]
    var repeatMode: RepeatMode
    var weekdays: Set<Weekday>
    var startDate: Date
    var hasEndDate: Bool
    var endDate: Date
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
        self.times = medication?.schedule.times ?? Self.defaultTimes()
        self.isActive = medication?.isActive ?? true
        self.startDate = medication?.schedule.startDate ?? .now
        self.endDate = medication?.schedule.endDate ?? .now
        self.hasEndDate = medication?.schedule.endDate != nil
        
        switch medication?.schedule.recurrence {
        case .daysOfWeek(let days):
            self.repeatMode = .specificDays
            self.weekdays = days
        default:
            self.repeatMode = .daily
            self.weekdays = []
        }
    }
    
    var isEditing: Bool {
        medication != nil
    }
    
    var title: String {
        isEditing ? "Edit Medication" : "New Medication"
    }
    
    func toggleWeekday(_ weekday: Weekday) {
        if weekdays.contains(weekday) {
            weekdays.remove(weekday)
        }
        else {
            weekdays.insert(weekday)
        }
    }
    
    func addTime() {
        guard let time = try? MedTime(hour: 12, minute: 0) else { return }
        times.append(time)
    }
    
    func removeTime(id: UUID) {
        guard times.count > 1 else { return }
        times.removeAll { $0.id == id }
    }
    
    func updateTime(id: UUID, to date: Date) {
        guard let index = times.firstIndex(where: { $0.id == id }) else { return }
        
        let value = date.hourAndMinute
        
        guard let updated = try? MedTime(id: id, hour: value.hour, minute: value.minute) else { return }
        
        times[index] = updated
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
            let updated = Medication(
                id: medication?.id ?? UUID(),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                dosage: Dosage(amount: amount, unit: unit),
                schedule: MedicationSchedule(
                    times: times.sorted(),
                    recurrence: recurrence,
                    startDate: startDate,
                    endDate: hasEndDate ? endDate : nil
                ),
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
    
    private var recurrence: Recurrence {
        switch repeatMode {
        case .daily: .daily
        case .specificDays: .daysOfWeek(weekdays)
        }
    }
    
    private static func defaultTimes() -> [MedTime] {
        guard let time = try? MedTime(hour: 9, minute: 0) else { return [] }
        return [time]
    }
    
    private static func text(for amount: Double) -> String {
        amount.rounded() == amount
            ? String(Int(amount))
            : String(amount)
    }
}
