//
//  TodayViewModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class TodayViewModel {
    private(set) var state: TodayState = .loading
    private(set) var selectedDay: Date
    var errorMessage: String?
    
    private let loadHistory: LoadDoseHistoryUseCase
    private let recordDose: RecordDoseUseCase
    private let saveMedication: SaveMedicationUseCase
    private let calendar: Calendar
    private let currentDate: @Sendable () -> Date
    
    public init(
        loadHistory: LoadDoseHistoryUseCase,
        recordDose: RecordDoseUseCase,
        saveMedication: SaveMedicationUseCase,
        calendar: Calendar = .current,
        currentDate: @escaping @Sendable () -> Date = { .now }
    ) {
        self.loadHistory = loadHistory
        self.recordDose = recordDose
        self.saveMedication = saveMedication
        self.calendar = calendar
        self.currentDate = currentDate
        self.selectedDay = calendar.startOfDay(for: currentDate())
    }
    
    public func start() async {
        await load()
    }
    
    func load() async {
        if case .failure = state {
            state = .loading
        }
        
        let today = calendar.startOfDay(for: currentDate())
        
        do {
            let summaries = try await loadHistory.execute(endingOn: today)
            let week = week(endingOn: today, from: summaries)
            
            state = .loaded(week)
            
            if !week.contains(where: { calendar.isDate($0.date, inSameDayAs: selectedDay) }) {
                selectedDay = today
            }
        }
        catch {
            state = .failure(message: message(for: error))
        }
    }
    
    func select(_ day: Date) {
        selectedDay = calendar.startOfDay(for: day)
    }
    
    func record(_ dose: ScheduledDose, as status: DoseStatus) async {
        do {
            replace(try await recordDose.execute(dose, status: status, now: currentDate()))
        }
        catch {
            errorMessage = message(for: error)
        }
    }
    
    func makeNewMedicationEditor() -> MedicationEditorViewModel {
        MedicationEditorViewModel(medication: nil, saveMedication: saveMedication)
    }
    
    var week: [DoseDaySummary] {
        guard case .loaded(let week) = state else { return [] }
        
        return week
    }
    
    var selectedDoses: [ScheduledDose] {
        week.first { calendar.isDate($0.date, inSameDayAs: selectedDay) }?.doses ?? []
    }
    
    var isTodaySelected: Bool {
        calendar.isDate(selectedDay, inSameDayAs: currentDate())
    }
    
    var title: String {
        selectedDay.formatted(.dateTime.weekday(.wide).day().month(.abbreviated).locale(AppLanguage.current.locale))
    }
    
    var takenCount: Int {
        selectedDoses.count { $0.log?.status == .taken }
    }
    
    var progress: Double {
        selectedDoses.isEmpty ? 0 : Double(takenCount) / Double(selectedDoses.count)
    }
    
    var weekAdherence: Double {
        let doses = week.flatMap(\.doses)
        
        guard !doses.isEmpty else { return 0 }
        
        return Double(doses.count { $0.log?.status == .taken }) / Double(doses.count)
    }
    
    var nextDose: ScheduledDose? {
        guard isTodaySelected else { return nil }
        
        return selectedDoses
            .filter { state(of: $0) == .pending }
            .min { $0.scheduledDate < $1.scheduledDate }
    }
    
    var isDayComplete: Bool {
        !selectedDoses.isEmpty && takenCount == selectedDoses.count
    }
    
    func isSelected(_ day: Date) -> Bool {
        calendar.isDate(day, inSameDayAs: selectedDay)
    }
    
    func countdown(to dose: ScheduledDose) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = AppLanguage.current.locale
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: dose.scheduledDate, relativeTo: currentDate())
    }
    
    func state(of dose: ScheduledDose) -> DoseState {
        dose.state(at: currentDate())
    }
    
    func doses(in period: DosePeriod) -> [ScheduledDose] {
        selectedDoses.filter { DosePeriod.of($0.scheduledDate) == period }
    }
    
    private func week(endingOn today: Date, from summaries: [DoseDaySummary]) -> [DoseDaySummary] {
        (0..<LoadDoseHistoryUseCase.defaultDayCount)
            .reversed()
            .compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
            .map { day in
                summaries.first { calendar.isDate($0.date, inSameDayAs: day) }
                    ?? DoseDaySummary(date: day, doses: [])
            }
    }
    
    private func replace(_ dose: ScheduledDose) {
        guard case .loaded(let week) = state else { return }
        
        state = .loaded(
            week.map { summary in
                guard summary.doses.contains(where: { $0.id == dose.id }) else { return summary }
                
                return DoseDaySummary(
                    date: summary.date,
                    doses: summary.doses.map { $0.id == dose.id ? dose : $0 }
                )
            }
        )
    }
}
