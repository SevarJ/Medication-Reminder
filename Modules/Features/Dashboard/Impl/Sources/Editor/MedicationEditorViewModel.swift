//
//  MedicationEditorViewModel.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppFormatters
import AppLocalization
import Domain
import Foundation
import Observation

@MainActor
@Observable
final class MedicationEditorViewModel: Identifiable {
    let id = UUID()
    
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
    var photo: Data?
    var notes: String
    var stockText: String
    var errorMessage: String?
    private(set) var isSaving = false
    
    /// The step the adding flow is on.
    private(set) var step: EditorStep = .details
    /// The reminder whose wheel is open.
    var selectedTimeId: UUID?
    
    let medication: Medication?
    private let saveMedication: SaveMedicationUseCase
    
    init(medication: Medication?, saveMedication: SaveMedicationUseCase) {
        self.medication = medication
        self.saveMedication = saveMedication
        self.name = medication?.name ?? ""
        self.amountText = medication.map { Self.text(for: $0.dosage.amount) } ?? "1"
        self.unit = medication?.dosage.unit ?? .tablet
        let times = medication?.schedule.times ?? Self.defaultTimes()
        self.times = times
        self.selectedTimeId = times.first?.id
        self.isActive = medication?.isActive ?? true
        self.startDate = medication?.schedule.startDate ?? .now
        self.endDate = medication?.schedule.endDate ?? .now
        self.hasEndDate = medication?.schedule.endDate != nil
        self.photo = medication?.photo
        self.notes = medication?.notes ?? ""
        self.stockText = medication?.stock.map(Self.text(for:)) ?? ""
        
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
        isEditing ? L10n.Editor.editTitle : L10n.Editor.newTitle
    }
    
    var isFirstStep: Bool {
        step == EditorStep.allCases.first
    }
    
    var isLastStep: Bool {
        step == EditorStep.allCases.last
    }
    
    var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }
    
    var dosage: Dosage? {
        amount.map { Dosage(amount: $0, unit: unit) }
    }
    
    var recurrence: Recurrence {
        switch repeatMode {
        case .daily: .daily
        case .specificDays: .daysOfWeek(weekdays)
        }
    }
    
    /// What is left, or nil when the field is empty or does not hold a number.
    var stock: Double? {
        Double(stockText.replacingOccurrences(of: ",", with: "."))
    }
    
    // MARK: Steps
    
    /// Moves to the next step once the current one holds valid input.
    func next() {
        guard validate(step),
              let index = EditorStep.allCases.firstIndex(of: step),
              index + 1 < EditorStep.allCases.count
        else { return }
        
        step = EditorStep.allCases[index + 1]
    }
    
    func back() {
        guard let index = EditorStep.allCases.firstIndex(of: step), index > 0 else { return }
        
        step = EditorStep.allCases[index - 1]
    }
    
    func summary(of step: EditorStep) -> String {
        switch step {
        case .details:
            let dose = dosage?.displayText ?? amountText
            let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            return title.isEmpty ? dose : "\(title) · \(dose)"
        case .schedule:
            return "\(recurrence.displayText) · \(times.sorted().map(\.displayText).joined(separator: ", "))"
        case .duration:
            let start = shortDate(startDate)
            
            return hasEndDate ? "\(start) – \(shortDate(endDate))" : L10n.Form.from(start)
        case .extras:
            let parts = [
                stock.map { Dosage(amount: $0, unit: unit).displayText + " " + L10n.Form.leftSuffix },
                notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
            ].compactMap { $0 }
            
            return parts.isEmpty ? L10n.Form.notSet : parts.joined(separator: " · ")
        }
    }
    
    /// Checks one step and reports the first problem, so adding can stop before moving on.
    func validate(_ step: EditorStep) -> Bool {
        let problem: String?
        
        switch step {
        case .details:
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                problem = ErrorFormatter.message(for: DomainError.nameEmpty)
            }
            else if (amount ?? 0) <= 0 {
                problem = L10n.Error.invalidAmount
            }
            else {
                problem = nil
            }
        case .schedule:
            if weekdays.isEmpty && repeatMode == .specificDays {
                problem = ErrorFormatter.message(for: DomainError.weekdayUnselected)
            }
            else if Set(times.map { $0.hour * 60 + $0.minute }).count != times.count {
                problem = ErrorFormatter.message(for: DomainError.duplicateTime)
            }
            else {
                problem = nil
            }
        case .duration:
            problem = hasEndDate && endDate < startDate
                ? ErrorFormatter.message(for: DomainError.invalidDateRange)
                : nil
        case .extras:
            problem = !stockText.isEmpty && (stock ?? -1) < 0 ? L10n.Form.invalidStock : nil
        }
        
        errorMessage = problem
        
        return problem == nil
    }
    
    // MARK: Dose
    
    func stepAmount(by direction: Double) {
        let size = unit.stepSize
        let current = amount ?? 0
        let next = max(size, current + direction * size)
        
        amountText = Self.text(for: next)
    }
    
    // MARK: Times
    
    func toggleWeekday(_ weekday: Weekday) {
        if weekdays.contains(weekday) {
            weekdays.remove(weekday)
        }
        else {
            weekdays.insert(weekday)
        }
    }
    
    var canAddTime: Bool {
        times.count < MedicationSchedule.maxTimes
    }
    
    func addTime() {
        guard canAddTime, let time = try? MedTime(hour: 12, minute: 0) else { return }
        
        times.append(time)
        selectedTimeId = time.id
    }
    
    func removeTime(id: UUID) {
        guard times.count > 1 else { return }
        
        times.removeAll { $0.id == id }
        
        if selectedTimeId == id {
            selectedTimeId = times.first?.id
        }
    }
    
    func updateTime(id: UUID, to date: Date) {
        guard let index = times.firstIndex(where: { $0.id == id }) else { return }
        
        let value = date.hourAndMinute
        
        guard let updated = try? MedTime(id: id, hour: value.hour, minute: value.minute) else { return }
        
        times[index] = updated
    }
    
    // MARK: Save
    
    func save() async -> Bool {
        guard let dosage, dosage.amount > 0 else {
            errorMessage = L10n.Error.invalidAmount
            return false
        }
        
        guard validate(.extras) else { return false }
        
        isSaving = true
        defer { isSaving = false }
        
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let updated = Medication(
                id: medication?.id ?? UUID(),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                dosage: dosage,
                schedule: MedicationSchedule(
                    times: times.sorted(),
                    recurrence: recurrence,
                    startDate: startDate,
                    endDate: hasEndDate ? endDate : nil
                ),
                isActive: isActive,
                createdDate: medication?.createdDate ?? .now,
                photo: photo,
                notes: trimmedNotes.isEmpty ? nil : String(trimmedNotes.prefix(Medication.notesLimit)),
                stock: stock
            )
            
            try await saveMedication.execute(updated)
            
            return true
        }
        catch is ReminderError {
            return true
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
            return false
        }
    }
    
    private func shortDate(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).locale(AppLanguage.current.locale))
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
