//
//  MedicationEntity.swift
//  Persistence
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftData
import Foundation

@Model
final class MedicationEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var dosageAmount: Double
    var dosageUnit: String
    var times: [MedTimeRecord]
    var isActive: Bool
    var createdDate: Date
    
    init(
        id: UUID,
        name: String,
        dosageAmount: Double,
        dosageUnit: String,
        times: [MedTimeRecord],
        isActive: Bool,
        createdDate: Date
    ) {
        self.id = id
        self.name = name
        self.dosageAmount = dosageAmount
        self.dosageUnit = dosageUnit
        self.times = times
        self.isActive = isActive
        self.createdDate = createdDate
    }
}
