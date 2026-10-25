//
//  ThemeColors.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct ThemeColors: Sendable {
    public let background = Color(light: Palette.canvasLight, dark: Palette.black)
    public let surface = Color(light: Palette.white, dark: Palette.charcoal)
    public let fill = Color(light: Palette.fillLight, dark: Palette.fillDark)
    public let separator = Color(light: Palette.separatorLight, dark: Palette.separatorDark)

    public let textPrimary = Color(light: Palette.charcoal, dark: Palette.white)
    public let textSecondary = Color(light: Palette.gray, dark: Palette.grayDark)

    /// Brand violet for fills, rings and icons.
    public let accent = Color(light: Palette.violet, dark: Palette.violetBright)
    /// Brand violet for text and small glyphs on a surface.
    public let accentText = Color(light: Palette.violetDeep, dark: Palette.violetTextDark)
    public let accentTint = Color(light: Palette.violetTintLight, dark: Palette.violetTintDark)
    /// Deep violet for solid brand surfaces such as the hero card and the primary button, white content sits on top of it.
    public let hero = Color(light: Palette.violetDeep, dark: Palette.violetDeep)

    public let onHero = Color.white

    public let success = Color(light: Palette.green, dark: Palette.green)
    public let successText = Color(light: Palette.greenText, dark: Palette.greenTextDark)
    public let successTint = Color(light: Palette.greenTintLight, dark: Palette.greenTintDark)
    public let warning = Color(light: Palette.amberText, dark: Palette.amberTextDark)
    public let warningTint = Color(light: Palette.amberTintLight, dark: Palette.amberTintDark)
    public let info = Color(light: Palette.blueText, dark: Palette.blueTextDark)
    public let infoTint = Color(light: Palette.blueTintLight, dark: Palette.blueTintDark)
    public let danger = Color(light: Palette.red, dark: Palette.redBright)
}

public extension Color {
    static let theme = ThemeColors()
}
