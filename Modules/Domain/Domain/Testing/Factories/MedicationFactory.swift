//
//  MedicationFactory.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Domain
import Foundation

public func makeMedication(
    id: UUID = UUID(),
    name: String = "Vitamin D",
    dosage: Dosage = Dosage(amount: 10, unit: .drop),
    times: [(Int, Int)] = [(9, 0)],
    recurrence: Recurrence = .daily,
    startDate: Date = .now,
    endDate: Date? = nil,
    isActive: Bool = true,
    createdDate: Date = .now
) throws -> Medication {
    Medication(
        id: id,
        name: name,
        dosage: dosage,
        schedule: MedicationSchedule(
            times: try times.map { try MedTime(hour: $0.0, minute: $0.1) },
            recurrence: recurrence,
            startDate: startDate,
            endDate: endDate
        ),
        isActive: isActive,
        createdDate: createdDate
    )
}
