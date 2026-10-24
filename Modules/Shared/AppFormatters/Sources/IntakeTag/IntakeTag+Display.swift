//
//  IntakeTag+Display.swift
//  AppFormatters
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Domain
import Foundation

public extension IntakeTag {
    var displayText: String {
        switch self {
        case .beforeMeal: L10n.IntakeTag.beforeMeal
        case .afterMeal: L10n.IntakeTag.afterMeal
        case .emptyStomach: L10n.IntakeTag.emptyStomach
        case .custom(let text): text
        }
    }
}

public extension Array where Element == IntakeTag {
    var displayText: String? {
        isEmpty ? nil : map(\.displayText).joined(separator: ", ")
    }
}
