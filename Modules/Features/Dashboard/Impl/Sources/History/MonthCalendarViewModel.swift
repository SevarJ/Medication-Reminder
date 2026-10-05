//
//  MonthCalendarViewModel.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import AppLocalization
import Domain
import Foundation
import Observation

/// The month the expanded calendar on the Today screen shows, and the doses of its days.
@MainActor
@Observable
final class MonthCalendarViewModel {
    private(set) var state: HistoryState = .loading
    private(set) var month: Date
    private(set) var earliestMonth: Date?
    
    private let loadMonth: LoadMonthHistoryUseCase
    private let calendar: Calendar
    private let currentDate: @Sendable () -> Date
    
    /// Months older than the cached window, which cost a server read and cannot change on this device.
    private var memo: [Date: [DoseDaySummary]] = [:]
    private var shownMonth: Date?
    
    init(
        loadMonth: LoadMonthHistoryUseCase,
        calendar: Calendar,
        currentDate: @escaping @Sendable () -> Date
    ) {
        self.loadMonth = loadMonth
        self.calendar = calendar
        self.currentDate = currentDate
        self.month = Self.startOfMonth(containing: currentDate(), calendar: calendar)
    }
    
    // MARK: Loading
    
    func load() async {
        let requested = month
        
        earliestMonth = try? await loadMonth.earliestMonth()
        
        if let cached = memo[requested] {
            show(cached, for: requested)
            return
        }
        
        if shownMonth != requested {
            state = .loading
        }
        
        do {
            let days = try await loadMonth.execute(month: requested, now: currentDate())
            
            guard month == requested else { return }
            
            if isOlderThanCache(requested) {
                memo[requested] = days
            }
            
            show(days, for: requested)
        }
        catch {
            guard month == requested else { return }
            
            shownMonth = nil
            state = .failure
        }
    }
    
    /// Starts over, for when the medications or the account's data changed.
    func reload() async {
        invalidate()
        
        await load()
    }
    
    /// Forgets what was loaded, so the next `load()` reads it again.
    func invalidate() {
        memo = [:]
        shownMonth = nil
    }
    
    func showMonth(containing day: Date) async {
        await show(month: Self.startOfMonth(containing: day, calendar: calendar))
    }
    
    func showPreviousMonth() async {
        guard canShowPreviousMonth else { return }
        
        await show(month: shifted(month, by: -1))
    }
    
    func showNextMonth() async {
        guard canShowNextMonth else { return }
        
        await show(month: shifted(month, by: 1))
    }
    
    /// Keeps a dose that was just recorded in step with the month on screen.
    func replace(_ dose: ScheduledDose) {
        guard case .loaded(let days) = state else { return }
        
        state = .loaded(
            days.map { summary in
                guard summary.doses.contains(where: { $0.id == dose.id }) else { return summary }
                
                return DoseDaySummary(
                    date: summary.date,
                    doses: summary.doses.map { $0.id == dose.id ? dose : $0 }
                )
            }
        )
    }
    
    // MARK: Month
    
    var canShowPreviousMonth: Bool {
        earliestMonth.map { month > $0 } ?? false
    }
    
    var canShowNextMonth: Bool {
        month < Self.startOfMonth(containing: currentDate(), calendar: calendar)
    }
    
    var title: String {
        month.formatted(.dateTime.month(.wide).year().locale(AppLanguage.current.locale))
    }
    
    /// One entry per grid cell: `nil` pads the first week up to the weekday the month starts on.
    var gridDays: [Date?] {
        guard let days = calendar.range(of: .day, in: .month, for: month) else { return [] }
        
        let padding = (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7
        
        return Array(repeating: nil, count: padding)
            + days.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month) }
    }
    
    var weekdayHeaders: [String] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: month) else { return [] }
        
        return (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: week.start) }
            .map { $0.formatted(.dateTime.weekday(.narrow).locale(AppLanguage.current.locale)) }
    }
    
    // MARK: Days
    
    var isLoaded: Bool {
        if case .loaded = state { true } else { false }
    }
    
    var days: [DoseDaySummary] {
        guard case .loaded(let days) = state else { return [] }
        
        return days
    }
    
    func summary(on day: Date) -> DoseDaySummary? {
        days.first { calendar.isDate($0.date, inSameDayAs: day) }
    }
    
    func outcome(on day: Date) -> DayOutcome {
        summary(on: day)?.outcome(at: currentDate()) ?? .none
    }
    
    /// The history ends today.
    func isSelectable(_ day: Date) -> Bool {
        calendar.startOfDay(for: day) <= calendar.startOfDay(for: currentDate())
    }
    
    // MARK: Totals
    
    var takenCount: Int {
        count(of: .taken)
    }
    
    var skippedCount: Int {
        count(of: .skipped)
    }
    
    var missedCount: Int {
        count(of: .missed)
    }
    
    /// Taken doses out of those that have come due, or `nil` while nothing has.
    var adherence: Double? {
        let due = takenCount + skippedCount + missedCount
        
        guard due > 0 else { return nil }
        
        return Double(takenCount) / Double(due)
    }
    
    // MARK: Helpers
    
    private func show(month: Date) async {
        self.month = month
        
        await load()
    }
    
    private func show(_ days: [DoseDaySummary], for month: Date) {
        shownMonth = month
        state = .loaded(days)
    }
    
    private func isOlderThanCache(_ month: Date) -> Bool {
        let today = calendar.startOfDay(for: currentDate())
        
        guard let cacheStart = calendar.date(byAdding: .day, value: -RefreshAccountDataUseCase.doseLogDays, to: today),
              let end = calendar.date(byAdding: .month, value: 1, to: month)
        else {
            return false
        }
        
        return end <= cacheStart
    }
    
    private func count(of state: DoseState) -> Int {
        let now = currentDate()
        
        return days.flatMap(\.doses).count { $0.state(at: now) == state }
    }
    
    private func shifted(_ month: Date, by value: Int) -> Date {
        calendar.date(byAdding: .month, value: value, to: month) ?? month
    }
    
    private static func startOfMonth(containing date: Date, calendar: Calendar) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
    }
}
