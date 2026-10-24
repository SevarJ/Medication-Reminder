//
//  IntakeTag.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Foundation

public enum IntakeTag: Hashable, Sendable {
    case beforeMeal
    case afterMeal
    case emptyStomach
    case custom(String)

    public static let presets: [IntakeTag] = [.beforeMeal, .afterMeal, .emptyStomach]
    public static let customLimit = 40
    public static let maxCount = 10

    public static func custom(named text: String) -> IntakeTag? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return nil }

        return .custom(String(trimmed.prefix(customLimit)))
    }

    public var isCustom: Bool {
        if case .custom = self { true } else { false }
    }
}
