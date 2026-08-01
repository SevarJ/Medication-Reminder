//
//  Dosage.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

public struct Dosage: Sendable, Equatable, Hashable {
    public let amount: Double
    public let unit: DosageUnit
    
    public init(amount: Double, unit: DosageUnit) {
        self.amount = amount
        self.unit = unit
    }
}

public enum DosageUnit: Sendable, CaseIterable {
    case mg, ml, tablet, drop
}
