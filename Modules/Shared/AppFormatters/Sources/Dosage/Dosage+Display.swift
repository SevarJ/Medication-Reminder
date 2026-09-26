//
//  Dosage+Display.swift
//  AppFormatters
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppLocalization
import Domain
import Foundation

public extension Dosage {
    var displayText: String {
        let amountText = amount.formatted(.number.precision(.fractionLength(0...2)).locale(AppLanguage.current.locale))
        let wholeAmount = Int(exactly: amount)
        
        switch unit {
        case .mg:
            return L10n.Dosage.milligrams(amountText)
        case .ml:
            return L10n.Dosage.milliliters(amountText)
        case .tablet:
            return wholeAmount.map(L10n.Dosage.tablets) ?? L10n.Dosage.tabletsFraction(amountText)
        case .drop:
            return wholeAmount.map(L10n.Dosage.drops) ?? L10n.Dosage.dropsFraction(amountText)
        }
    }
}

public extension DosageUnit {
    var displayText: String {
        switch self {
        case .mg: L10n.Unit.milligram
        case .ml: L10n.Unit.milliliter
        case .tablet: L10n.Unit.tablet
        case .drop: L10n.Unit.drop
        }
    }
}
