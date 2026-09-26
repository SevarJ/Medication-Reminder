//
//  MedicationFactory.swift
//  NotificationsKit
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain
import Foundation

func makeMedication(
    name: String = "Vitamin D",
    times: [(Int, Int)] = [(9, 0)],
    recurrence: Recurrence = .daily,
    startDate: Date = .now,
    endDate: Date? = nil,
    isActive: Bool = true
) throws -> Medication {
    Medication(
        name: name,
        dosage: Dosage(amount: 10, unit: .drop),
        schedule: MedicationSchedule(
            times: try times.map { try MedTime(hour: $0.0, minute: $0.1) },
            recurrence: recurrence,
            startDate: startDate,
            endDate: endDate
        ),
        isActive: isActive,
        createdDate: .now
    )
}
