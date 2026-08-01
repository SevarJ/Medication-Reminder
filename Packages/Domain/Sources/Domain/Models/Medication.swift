//
//  Medication.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

public struct Medication: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let dosage: Dosage
    public let times: [MedTime]
    public let isActive: Bool
    public let createdDate: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        dosage: Dosage,
        times: [MedTime],
        isActive: Bool,
        createdDate: Date
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.times = times
        self.isActive = isActive
        self.createdDate = createdDate
    }
    
    public func updating(isActive: Bool) -> Medication {
        Medication(
            id: id,
            name: name,
            dosage: dosage,
            times: times,
            isActive: isActive,
            createdDate: createdDate
        )
    }
}
