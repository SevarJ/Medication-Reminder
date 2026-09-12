//
//  Dosage+Display.swift
//  Domain
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Foundation

public extension Dosage {
    var displayText: String {
        "\(Self.amountFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)") \(unit.displayText)"
    }
    
    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
}

public extension DosageUnit {
    var displayText: String {
        switch self {
        case .mg: return "mg"
        case .ml: return "ml"
        case .tablet: return "tablet"
        case .drop: return "drop"
        }
    }
}
