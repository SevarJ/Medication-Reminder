//
//  TodayViewModel.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppFormatters
import AppLocalization
import Domain
import Foundation
import Observation

@MainActor
@Observable
final class TodayViewModel {
    private(set) var state: TodayState = .loading
    private(set) var selectedDay: Date
    /// Whether the week strip is opened up into the month calendar.
    private(set) var isExpanded = false
    var errorMessage: String?
    
    let monthCalendar: MonthCalendarViewModel
    
    private let loadHistory: LoadDoseHistoryUseCase
    private let recordDose: RecordDoseUseCase
    private let saveMedication: SaveMedicationUseCase
    private let makeDetail: @MainActor (Medication) -> MedicationDetailViewModel
    private let calendar: Calendar
    private let currentDate: @Sendable () -> Date
    
    init(
        loadHistory: LoadDoseHistoryUseCase,
        loadMonth: LoadMonthHistoryUseCase,
        recordDose: RecordDoseUseCase,
        saveMedication: SaveMedicationUseCase,
        makeDetail: @escaping @MainActor (Medication) -> MedicationDetailViewModel,
        calendar: Calendar = .current,
        currentDate: @escaping @Sendable () -> Date = { .now }
    ) {
        self.loadHistory = loadHistory
        self.recordDose = recordDose
        self.saveMedication = saveMedication
        self.makeDetail = makeDetail
        self.calendar = calendar
        self.currentDate = currentDate
        self.selectedDay = calendar.startOfDay(for: currentDate())
        self.monthCalendar = MonthCalendarViewModel(
            loadMonth: loadMonth,
            calendar: calendar,
            currentDate: currentDate
        )
    }
    
    func start() async {
        // Whatever the calendar loaded may be out of date now. It is read again when it opens, or right away if it already is.
        if isExpanded {
            await monthCalendar.reload()
        }
        else {
            monthCalendar.invalidate()
        }
        
        await load()
    }
    
    /// Picks up changes made elsewhere, such as when the app returns from the background.
    func refresh() async {
        await load()
        
        if isExpanded {
            await monthCalendar.load()
        }
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
            
            if !isExpanded && !week.contains(where: { calendar.isDate($0.date, inSameDayAs: selectedDay) }) {
                selectedDay = today
            }
        }
        catch {
            state = .failure(message: ErrorFormatter.message(for: error))
        }
    }
    
    func select(_ day: Date) {
        guard monthCalendar.isSelectable(day) else { return }
        
        selectedDay = calendar.startOfDay(for: day)
    }
    
    func toggleCalendar() async {
        if isExpanded {
            isExpanded = false
            
            // The strip only reaches back a week.
            if !isRecent(selectedDay) {
                selectedDay = calendar.startOfDay(for: currentDate())
            }
        }
        else {
            isExpanded = true
            
            await monthCalendar.showMonth(containing: selectedDay)
        }
    }
    
    func record(_ dose: ScheduledDose, as status: DoseStatus) async {
        do {
            let recorded = try await recordDose.execute(dose, status: status, now: currentDate())
            
            replace(recorded)
            monthCalendar.replace(recorded)
        }
        catch {
            errorMessage = ErrorFormatter.message(for: error)
        }
    }
    
    func makeDetailViewModel(for medication: Medication) -> MedicationDetailViewModel {
        makeDetail(medication)
    }
    
    func makeNewMedicationEditor() -> MedicationEditorViewModel {
        MedicationEditorViewModel(medication: nil, saveMedication: saveMedication)
    }
    
    var week: [DoseDaySummary] {
        guard case .loaded(let week) = state else { return [] }
        
        return week
    }
    
    var selectedDoses: [ScheduledDose] {
        selectedSummary?.doses ?? []
    }
    
    /// Whether the doses of the selected day are known. An older day waits for the calendar.
    var isSelectedDayLoaded: Bool {
        isRecent(selectedDay) || monthCalendar.isLoaded
    }
    
    /// Only the last week can be changed.
    func isEditable(_ dose: ScheduledDose) -> Bool {
        isRecent(dose.scheduledDate)
    }
    
    /// What the calendar header says: the month on screen, or the current one while it is closed.
    var calendarTitle: String {
        isExpanded ? monthCalendar.title : currentDate().formatted(.dateTime.month(.wide).year().locale(AppLanguage.current.locale))
    }
    
    var isTodaySelected: Bool {
        calendar.isDate(selectedDay, inSameDayAs: currentDate())
    }
    
    /// The selected day in full, as the heading above its doses.
    var fullTitle: String {
        selectedDay.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(AppLanguage.current.locale))
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
    
    private var selectedSummary: DoseDaySummary? {
        week.first { calendar.isDate($0.date, inSameDayAs: selectedDay) }
            ?? monthCalendar.summary(on: selectedDay)
    }
    
    /// Whether the day is one of the last seven, which the week strip shows and the Today screen can change.
    private func isRecent(_ day: Date) -> Bool {
        let today = calendar.startOfDay(for: currentDate())
        let day = calendar.startOfDay(for: day)
        
        guard let first = calendar.date(byAdding: .day, value: -(LoadDoseHistoryUseCase.defaultDayCount - 1), to: today) else {
            return false
        }
        
        return day >= first && day <= today
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
