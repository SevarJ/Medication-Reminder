//
//  ThemeColors.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct ThemeColors: Sendable {
    public let background = Color(
        light: Palette.grouped,
        dark: Palette.black
    )
    public let surface = Color(
        light: Palette.white,
        dark: Palette.charcoal
    )
    public let accent = Color(
        light: Palette.teal,
        dark: Palette.tealBright
    )
    public let accentTint = Color(
        light: Palette.tealTintLight,
        dark: Palette.tealTintDark
    )
    public let textPrimary = Color(
        light: Palette.charcoal,
        dark: Palette.white
    )
    public let textSecondary = Color(
        light: Palette.gray,
        dark: Palette.gray
    )
    public let danger = Color(
        light: Palette.red,
        dark: Palette.redBright
    )
    public let separator = Color(
        light: Palette.separatorLight,
        dark: Palette.separatorDark
    )
    public let morning = Color(
        light: Palette.amber,
        dark: Palette.amber
    )
    public let evening = Color(
        light: Palette.violet,
        dark: Palette.violet
    )
}

public extension Color {
    static let theme = ThemeColors()
}
