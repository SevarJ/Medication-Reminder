//
//  HistoryViewModel.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import AppLocalization
import Domain
import Foundation
import Observation

@MainActor
@Observable
final class HistoryViewModel {
    private(set) var state: HistoryState = .loading
    private(set) var month: Date
    private(set) var selectedDay: Date?
    private(set) var earliestMonth: Date?
    
    private let loadMonth: LoadMonthHistoryUseCase
    private let calendar: Calendar
    private let currentDate: @Sendable () -> Date
    
    /// Months older than the cached window, which cost a server read and cannot change on this device.
    private var memo: [Date: [DoseDaySummary]] = [:]
    private var shownMonth: Date?
    
    init(
        loadMonth: LoadMonthHistoryUseCase,
        calendar: Calendar = .current,
        currentDate: @escaping @Sendable () -> Date = { .now }
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
        memo = [:]
        
        await load()
    }
    
    func showPreviousMonth() async {
        guard canShowPreviousMonth else { return }
        
        await show(month: shifted(month, by: -1))
    }
    
    func showNextMonth() async {
        guard canShowNextMonth else { return }
        
        await show(month: shifted(month, by: 1))
    }
    
    func select(_ day: Date) {
        guard isSelectable(day) else { return }
        
        selectedDay = calendar.startOfDay(for: day)
    }
    
    /// The history ends today.
    func isSelectable(_ day: Date) -> Bool {
        calendar.startOfDay(for: day) <= calendar.startOfDay(for: currentDate())
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
    
    func isSelected(_ day: Date) -> Bool {
        selectedDay.map { calendar.isDate($0, inSameDayAs: day) } ?? false
    }
    
    var selectedDoses: [ScheduledDose] {
        selectedDay.flatMap(summary(on:))?.doses ?? []
    }
    
    var selectedTitle: String? {
        selectedDay?.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(AppLanguage.current.locale))
    }
    
    func state(of dose: ScheduledDose) -> DoseState {
        dose.state(at: currentDate())
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
        
        if !isSelectionValid(in: month) {
            selectedDay = defaultSelection(in: days)
        }
    }
    
    private func isSelectionValid(in month: Date) -> Bool {
        selectedDay.map { calendar.isDate($0, equalTo: month, toGranularity: .month) } ?? false
    }
    
    /// Today when the month holds it, otherwise the latest day that has doses.
    private func defaultSelection(in days: [DoseDaySummary]) -> Date? {
        let today = currentDate()
        
        if calendar.isDate(today, equalTo: month, toGranularity: .month) {
            return calendar.startOfDay(for: today)
        }
        
        return days.last?.date
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
        days.flatMap(\.doses).count { self.state(of: $0) == state }
    }
    
    private func shifted(_ month: Date, by value: Int) -> Date {
        calendar.date(byAdding: .month, value: value, to: month) ?? month
    }
    
    private static func startOfMonth(containing date: Date, calendar: Calendar) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
    }
}
