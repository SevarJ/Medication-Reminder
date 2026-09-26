//
//  ThemeFonts.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct ThemeFonts: Sendable {
    public let screenTitle = Font.system(.largeTitle, weight: .bold)
    public let rowTitle = Font.system(.headline)
    public let rowSubtitle = Font.system(.subheadline)
    public let caption = Font.system(.caption)
    public let badge = Font.system(.caption2, weight: .medium)
}

public extension Font {
    static let theme = ThemeFonts()
}
