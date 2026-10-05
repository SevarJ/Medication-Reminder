//
//  ThemeFonts.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct ThemeFonts: Sendable {
    public let screenTitle = Font.system(.largeTitle, weight: .bold)
    public let sectionTitle = Font.system(.title3, weight: .semibold)
    public let rowTitle = Font.system(.headline)
    public let rowSubtitle = Font.system(.subheadline)
    public let caption = Font.system(.caption)
    public let badge = Font.system(.caption, weight: .semibold)
    public let time = Font.system(.title3, design: .rounded, weight: .semibold).monospacedDigit()
    public let display = Font.system(.largeTitle, design: .rounded, weight: .bold).monospacedDigit()
}

public extension Font {
    static let theme = ThemeFonts()
}
