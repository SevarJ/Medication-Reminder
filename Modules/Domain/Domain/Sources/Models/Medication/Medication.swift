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
}
