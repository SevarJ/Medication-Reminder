//
//  MedicationFactory.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation
@testable import Domain

func makeMedication(
    name: String = "Vitamin D",
    times: [(Int, Int)] = [(9, 0)],
    isActive: Bool = true
) throws -> Medication {
    Medication(
        name: name,
        dosage: Dosage(amount: 10, unit: .drop),
        times: try times.map { try MedTime(hour: $0.0, minute: $0.1) },
        isActive: isActive,
        createdDate: .now
    )
}
