//
//  RefreshAccountDataUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Foundation

/// Replaces the cache with what the server holds for the account, then brings the reminders in line with it.
public struct RefreshAccountDataUseCase: Sendable {
    /// Days of dose history kept on the device. The app shows and edits the last week, older logs stay on the server.
    public static let doseLogDays = 14
    
    private let remoteMedications: any MedicationRemoteStore
    private let remoteDoseLogs: any DoseLogRemoteStore
    private let medicationCache: any MedicationCache
    private let doseLogCache: any DoseLogCache
    private let scheduler: any ReminderScheduling
    private let calendar: Calendar
    
    public init(
        remoteMedications: any MedicationRemoteStore,
        remoteDoseLogs: any DoseLogRemoteStore,
        medicationCache: any MedicationCache,
        doseLogCache: any DoseLogCache,
        scheduler: any ReminderScheduling,
        calendar: Calendar = .current
    ) {
        self.remoteMedications = remoteMedications
        self.remoteDoseLogs = remoteDoseLogs
        self.medicationCache = medicationCache
        self.doseLogCache = doseLogCache
        self.scheduler = scheduler
        self.calendar = calendar
    }
    
    public func execute(now: Date = .now) async throws {
        let today = calendar.startOfDay(for: now)
        let firstDay = calendar.date(byAdding: .day, value: -Self.doseLogDays, to: today) ?? today
        
        async let fetchedMedications = remoteMedications.fetchAll()
        async let fetchedLogs = remoteDoseLogs.fetch(from: firstDay)
        
        let (medications, logs) = try await (fetchedMedications, fetchedLogs)
        
        // A sign-out while the request was in flight must not refill the cache it is about to empty.
        try Task.checkCancellation()
        
        let cached = try await medicationCache.fetchAll()
        
        try await medicationCache.replaceAll(with: medications)
        try await doseLogCache.replaceAll(with: logs)
        
        await syncReminders(from: cached, to: medications)
    }
    
    /// Touches only the medications whose reminders would come out different, so an unchanged refresh leaves snoozed reminders alone.
    /// Scheduling fails while notifications are off, and the screens sync the reminders again once they are allowed.
    private func syncReminders(from cached: [Medication], to medications: [Medication]) async {
        let currentIds = Set(medications.map { $0.id })
        let unchanged = Set(cached.map(signature))
        
        for medication in cached where !currentIds.contains(medication.id) {
            try? await scheduler.cancel(for: medication.id)
        }
        
        for medication in medications where !unchanged.contains(signature(of: medication)) {
            if medication.isActive {
                try? await scheduler.schedule(for: medication)
            }
            else {
                try? await scheduler.cancel(for: medication.id)
            }
        }
    }
    
    private func signature(of medication: Medication) -> ReminderSignature {
        let schedule = medication.schedule
        
        return ReminderSignature(
            id: medication.id,
            name: medication.name,
            dosage: medication.dosage,
            times: schedule.times,
            recurrence: schedule.recurrence,
            firstDay: calendar.startOfDay(for: schedule.startDate),
            lastDay: schedule.endDate.map { calendar.startOfDay(for: $0) },
            isActive: medication.isActive
        )
    }
}

/// Everything a medication's reminders are built from. The dates count by day: that is all the schedule looks at,
/// and the server stores them less precisely than the device, so an exact comparison would see changes that are not there.
private struct ReminderSignature: Hashable {
    let id: UUID
    let name: String
    let dosage: Dosage
    let times: [MedTime]
    let recurrence: Recurrence
    let firstDay: Date
    let lastDay: Date?
    let isActive: Bool
}
