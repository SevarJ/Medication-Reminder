//
//  LocalNotificationScheduler.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation
import UserNotifications

struct LocalNotificationScheduler: ReminderScheduling {
    private let center: any UserNotificationCenter
    
    init(center: any UserNotificationCenter) {
        self.center = center
    }
    
    func schedule(for medication: Medication) async throws {
        try await cancel(for: medication.id)
        
        let status = await center.authorizationStatus()
        
        guard status == .authorized || status == .provisional else {
            throw ReminderError.authorizationDenied
        }
        
        for reminder in Self.reminders(for: medication) {
            try await center.add(reminder)
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
                    hour: time.hour,
                    minute: time.minute,
                    weekday: weekday
                )
            }
        }
    }
    
    func cancel(for medicationId: UUID) async throws {
        let prefix = Self.identifierPrefix(medicationId: medicationId)
        let identifiers = await center.pendingIdentifiers().filter { $0.hasPrefix(prefix) }
        
        guard !identifiers.isEmpty else { return }
        
        await center.removePending(identifiers: identifiers)
    }
    
    static func identifierPrefix(medicationId: UUID) -> String {
        "medication.\(medicationId.uuidString)."
    }
    
    static func identifier(medicationId: UUID, timeId: UUID, weekday: Int? = nil) -> String {
        let base = identifierPrefix(medicationId: medicationId) + timeId.uuidString
        
        guard let weekday else { return base }
        
        return base + ".\(weekday)"
    }
}
