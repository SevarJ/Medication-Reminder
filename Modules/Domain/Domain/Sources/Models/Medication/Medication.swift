//
//  Medication.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

public struct Medication: Identifiable, Equatable, Hashable, Sendable {
    public static let notesLimit = 300
    
    public let id: UUID
    public let name: String
    public let dosage: Dosage
    public let schedule: MedicationSchedule
    public let isActive: Bool
    public let createdDate: Date
    /// A small JPEG of the pack, if the user added one.
    public let photo: Data?
    public let notes: String?
    public let intakeTags: [IntakeTag]
    /// How much is left, counted in the unit of the dosage. Taking a dose uses up one dosage.
    public let stock: Double?
    
    public init(
        id: UUID = UUID(),
        name: String,
        dosage: Dosage,
        schedule: MedicationSchedule,
        isActive: Bool,
        createdDate: Date,
        photo: Data? = nil,
        notes: String? = nil,
        intakeTags: [IntakeTag] = [],
        stock: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.schedule = schedule
        self.isActive = isActive
        self.createdDate = createdDate
        self.photo = photo
        self.notes = notes
        self.intakeTags = intakeTags
        self.stock = stock
    }
    
    public func updating(isActive: Bool) -> Medication {
        Medication(
            id: id,
            name: name,
            dosage: dosage,
            schedule: schedule,
            isActive: isActive,
            createdDate: createdDate,
            photo: photo,
            notes: notes,
            intakeTags: intakeTags,
            stock: stock
        )
    }
    
    public func updating(stock: Double?) -> Medication {
        Medication(
            id: id,
            name: name,
            dosage: dosage,
            schedule: schedule,
            isActive: isActive,
            createdDate: createdDate,
            photo: photo,
            notes: notes,
            intakeTags: intakeTags,
            stock: stock
        )
    }
    
    /// Whole days the stock lasts at the usual pace, or nil when no stock is tracked.
    public var daysOfStockLeft: Int? {
        guard let stock else { return nil }
        
        let dosesPerDay = Double(schedule.times.count * schedule.recurrence.weekdays.count) / 7
        let usedPerDay = dosage.amount * dosesPerDay
        
        guard usedPerDay > 0 else { return nil }
        
        return Int((stock / usedPerDay).rounded(.down))
    }

    public static let lowStockDays = 3

    public func lowStockAlertDate(now: Date = .now, calendar: Calendar = .current) -> Date? {
        guard let days = daysOfStockLeft else { return nil }

        let today = calendar.startOfDay(for: now)

        if let endDate = schedule.endDate,
           let runOutDay = calendar.date(byAdding: .day, value: days, to: today),
           runOutDay > calendar.startOfDay(for: endDate) {
            return nil
        }

        guard days > Self.lowStockDays else { return now }

        guard let alertDay = calendar.date(byAdding: .day, value: days - Self.lowStockDays, to: today) else {
            return nil
        }

        let firstDay = max(alertDay, calendar.startOfDay(for: schedule.startDate))

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: firstDay) else { continue }

            if let firstDose = schedule.doses(on: day, calendar: calendar).first {
                return firstDose
            }
        }

        return nil
    }
}
