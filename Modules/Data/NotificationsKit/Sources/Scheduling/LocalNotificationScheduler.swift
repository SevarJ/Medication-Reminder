//
//  LocalNotificationScheduler.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

internal import AppFormatters
import Domain
import Foundation
internal import UserNotifications

struct LocalNotificationScheduler: ReminderScheduling {
    private let center: any UserNotificationCenter
    private let alertLog: any LowStockAlertLog
    
    init(center: any UserNotificationCenter, alertLog: any LowStockAlertLog) {
        self.center = center
        self.alertLog = alertLog
    }
    
    func schedule(for medication: Medication) async throws {
        try await cancel(for: medication.id)
        try await requireAuthorization()
        
        for reminder in Self.reminders(for: medication) {
            try await center.add(reminder)
        }
        
        try await addLowStockAlert(for: medication)
    }
    
    func scheduleLowStockAlert(for medication: Medication) async throws {
        let identifier = Self.lowStockIdentifier(medicationId: medication.id)
        
        if await center.pendingIdentifiers().contains(identifier) {
            await center.removePending(identifiers: [identifier])
        }
        
        try await requireAuthorization()
        try await addLowStockAlert(for: medication)
    }
    
    func addLowStockAlert(for medication: Medication, now: Date = .now) async throws {
        guard medication.isActive, let date = medication.lowStockAlertDate(now: now) else {
            alertLog.setAlertDate(nil, for: medication.id)
            return
        }
        
        let isDue = date <= now
        
        if isDue, let alerted = alertLog.alertDate(for: medication.id), alerted <= now {
            return
        }
        
        let days = min(medication.daysOfStockLeft ?? 0, Medication.lowStockDays)
        
        try await center.add(
            LowStockAlertRequest(
                identifier: Self.lowStockIdentifier(medicationId: medication.id),
                medicationId: medication.id,
                title: medication.name,
                body: days > 0 ? L10n.LowStock.daysLeft(days) : L10n.LowStock.outOfStock,
                fireDate: isDue ? nil : date
            )
        )
        
        alertLog.setAlertDate(isDue ? now : date, for: medication.id)
    }
    
    private func requireAuthorization() async throws {
        let status = await center.authorizationStatus()
        
        guard status == .authorized || status == .provisional else {
            throw ReminderError.authorizationDenied
        }
    }
    
    static func reminders(for medication: Medication, on date: Date = .now) -> [ReminderRequest] {
        let schedule = medication.schedule
        
        guard schedule.isWithinDateRange(on: date) else { return [] }
        
        let weekdays: [Int?] = switch schedule.recurrence {
        case .daily:
            [nil]
        case .daysOfWeek(let days):
            days.sorted().map { $0.rawValue }
        }
        
        return schedule.times.flatMap { time in
            weekdays.map { weekday in
                ReminderRequest(
                    identifier: identifier(
                        medicationId: medication.id,
                        timeId: time.id,
                        weekday: weekday
                    ),
                    medicationId: medication.id,
                    title: medication.name,
                    body: medication.dosage.displayText,
                    components: DateComponents(hour: time.hour, minute: time.minute, weekday: weekday),
                    repeats: true
                )
            }
        }
    }
    
    func snooze(_ medication: Medication, until date: Date) async throws {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        try await center.add(
            ReminderRequest(
                identifier: Self.snoozeIdentifier(medicationId: medication.id),
                medicationId: medication.id,
                title: medication.name,
                body: medication.dosage.displayText,
                components: components,
                repeats: false
            )
        )
    }
    
    static func snoozeIdentifier(medicationId: UUID) -> String {
        identifierPrefix(medicationId: medicationId) + "snooze." + UUID().uuidString
    }
    
    func cancel(for medicationId: UUID) async throws {
        let prefix = Self.identifierPrefix(medicationId: medicationId)
        let identifiers = await center.pendingIdentifiers().filter { $0.hasPrefix(prefix) }
        
        guard !identifiers.isEmpty else { return }
        
        await center.removePending(identifiers: identifiers)
    }
    
    func cancelAll() async throws {
        let identifiers = await center.pendingIdentifiers().filter { $0.hasPrefix(Self.reminderPrefix) }
        
        if !identifiers.isEmpty {
            await center.removePending(identifiers: identifiers)
        }
        
        await center.removeAllDelivered()
        alertLog.removeAll()
    }
    
    static let reminderPrefix = "medication."
    
    static func identifierPrefix(medicationId: UUID) -> String {
        reminderPrefix + "\(medicationId.uuidString)."
    }
    
    static func lowStockIdentifier(medicationId: UUID) -> String {
        identifierPrefix(medicationId: medicationId) + "lowStock"
    }
    
    static func identifier(medicationId: UUID, timeId: UUID, weekday: Int? = nil) -> String {
        let base = identifierPrefix(medicationId: medicationId) + timeId.uuidString
        
        guard let weekday else { return base }
        
        return base + ".\(weekday)"
    }
}
