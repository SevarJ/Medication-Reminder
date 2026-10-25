//
//  CategoryColor.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 25.10.26.
//

import SwiftUI

/// A colour that tells one item apart from its neighbours, such as a medication in a list.
public struct CategoryColor: Sendable {
    /// For glyphs and text on a surface.
    public let tint: Color
    /// For a solid card with white content on top.
    public let deep: Color

    public var background: Color {
        tint.opacity(0.15)
    }
}

public extension ThemeColors {
    static let categories = [
        CategoryColor(tint: Color(light: Palette.violet, dark: Palette.violetBright), deep: Color(Palette.violetDeep)),
        CategoryColor(tint: Color(light: Palette.blue, dark: Palette.blueBright), deep: Color(Palette.blueDeep)),
        CategoryColor(tint: Color(light: Palette.pink, dark: Palette.pinkBright), deep: Color(Palette.pinkDeep)),
        CategoryColor(tint: Color(light: Palette.cyan, dark: Palette.cyanBright), deep: Color(Palette.cyanDeep)),
        CategoryColor(tint: Color(light: Palette.orange, dark: Palette.orangeBright), deep: Color(Palette.orangeDeep)),
        CategoryColor(tint: Color(light: Palette.indigo, dark: Palette.indigoBright), deep: Color(Palette.indigoDeep))
    ]

    /// The same id always gets the same colour, on every launch.
    func category(for id: UUID) -> CategoryColor {
        let bytes = withUnsafeBytes(of: id.uuid) { Array($0) }
        let hash = bytes.reduce(UInt64(14_695_981_039_346_656_037)) { ($0 ^ UInt64($1)) &* 1_099_511_628_211 }
        return Self.categories[Int(hash % UInt64(Self.categories.count))]
    }
}
