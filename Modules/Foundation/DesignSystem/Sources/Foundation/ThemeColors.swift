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

    /// Brand green for fills, rings and icons.
    public let accent = Color(light: Palette.teal, dark: Palette.tealBright)
    /// Brand green for text and small glyphs on a surface.
    public let accentText = Color(light: Palette.tealText, dark: Palette.tealBright)
    public let accentTint = Color(light: Palette.tealTintLight, dark: Palette.tealTintDark)
    /// Deep green used for the one hero card on a screen, white content sits on top of it.
    public let hero = Color(light: Palette.tealDeep, dark: Palette.tealDeep)
    public let heroDeep = Color(light: Palette.tealDeeper, dark: Palette.tealDeeper)
    public let onHero = Color.white

    public let warning = Color(light: Palette.amberText, dark: Palette.amberTextDark)
    public let warningTint = Color(light: Palette.amberTintLight, dark: Palette.amberTintDark)
    public let info = Color(light: Palette.blueText, dark: Palette.blueTextDark)
    public let infoTint = Color(light: Palette.blueTintLight, dark: Palette.blueTintDark)
    public let danger = Color(light: Palette.red, dark: Palette.redBright)
}

public extension Color {
    static let theme = ThemeColors()
}
