//
//  Palette.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import UIKit

enum Palette {
    // Brand violet, taken from the app icon. `violetDeep` carries white text at AA contrast.
    static let violet = UIColor(hex: 0x7C3AED)
    static let violetBright = UIColor(hex: 0xA78BFA)
    static let violetDeep = UIColor(hex: 0x5B21B6)
    static let violetTextDark = UIColor(hex: 0xC4B5FD)
    static let violetTintLight = UIColor(hex: 0xF3EEFF)
    static let violetTintDark = UIColor(hex: 0x2A1D4D)

    // Medication colours, so each medication is easy to tell apart. `Deep` stops carry white text at AA contrast.
    static let blue = UIColor(hex: 0x2563EB)
    static let blueBright = UIColor(hex: 0x60A5FA)
    static let blueDeep = UIColor(hex: 0x1D4ED8)
    static let pink = UIColor(hex: 0xDB2777)
    static let pinkBright = UIColor(hex: 0xF472B6)
    static let pinkDeep = UIColor(hex: 0xBE185D)
    static let cyan = UIColor(hex: 0x0891B2)
    static let cyanBright = UIColor(hex: 0x22D3EE)
    static let cyanDeep = UIColor(hex: 0x0E7490)
    static let orange = UIColor(hex: 0xEA580C)
    static let orangeBright = UIColor(hex: 0xFB923C)
    static let orangeDeep = UIColor(hex: 0xC2410C)
    static let indigo = UIColor(hex: 0x4F46E5)
    static let indigoBright = UIColor(hex: 0x818CF8)
    static let indigoDeep = UIColor(hex: 0x4338CA)

    // Neutrals
    static let canvasLight = UIColor(hex: 0xF4F6F5)
    static let black = UIColor(hex: 0x000000)
    static let white = UIColor(hex: 0xFFFFFF)
    static let charcoal = UIColor(hex: 0x1C1C1E)
    static let gray = UIColor(hex: 0x6C6C70)
    static let grayDark = UIColor(hex: 0x98989F)
    static let fillLight = UIColor(hex: 0x767680, alpha: 0.10)
    static let fillDark = UIColor(hex: 0x767680, alpha: 0.24)

    // Supporting colours, each with a single meaning: emerald from the app icon is taken, amber needs attention, blue is calm information, red is destructive.
    static let green = UIColor(hex: 0x059669)
    static let greenText = UIColor(hex: 0x047857)
    static let greenTextDark = UIColor(hex: 0x34D399)
    static let greenTintLight = UIColor(hex: 0xE3F8EF)
    static let greenTintDark = UIColor(hex: 0x0F3326)
    static let amberText = UIColor(hex: 0x9A5B00)
    static let amberTextDark = UIColor(hex: 0xFFB84D)
    static let amberTintLight = UIColor(hex: 0xFFF1D6)
    static let amberTintDark = UIColor(hex: 0x3A2A0C)
    static let blueText = UIColor(hex: 0x3454C5)
    static let blueTextDark = UIColor(hex: 0x9DB2FF)
    static let blueTintLight = UIColor(hex: 0xE6ECFF)
    static let blueTintDark = UIColor(hex: 0x1B2547)
    static let red = UIColor(hex: 0xD92D20)
    static let redBright = UIColor(hex: 0xFF5A4F)

    static let separatorLight = UIColor(hex: 0x000000, alpha: 0.08)
    static let separatorDark = UIColor(hex: 0xFFFFFF, alpha: 0.12)
}
