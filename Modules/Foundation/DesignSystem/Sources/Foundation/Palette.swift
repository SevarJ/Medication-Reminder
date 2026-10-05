//
//  Palette.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import UIKit

enum Palette {
    // Brand green. `tealDeep` carries white text at AA contrast, `tealText` is the readable form on light surfaces.
    static let teal = UIColor(hex: 0x12A594)
    static let tealBright = UIColor(hex: 0x2ABFAD)
    static let tealDeep = UIColor(hex: 0x0B6E63)
    static let tealDeeper = UIColor(hex: 0x084D46)
    static let tealText = UIColor(hex: 0x0B7F72)
    static let tealTintLight = UIColor(hex: 0xE3F4F1)
    static let tealTintDark = UIColor(hex: 0x103832)

    // Neutrals
    static let canvasLight = UIColor(hex: 0xF4F6F5)
    static let black = UIColor(hex: 0x000000)
    static let white = UIColor(hex: 0xFFFFFF)
    static let charcoal = UIColor(hex: 0x1C1C1E)
    static let gray = UIColor(hex: 0x6C6C70)
    static let grayDark = UIColor(hex: 0x98989F)
    static let fillLight = UIColor(hex: 0x767680, alpha: 0.10)
    static let fillDark = UIColor(hex: 0x767680, alpha: 0.24)

    // Supporting colours, each with a single meaning: amber needs attention, blue is calm information, red is destructive.
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
