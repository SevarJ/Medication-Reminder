//
//  IconTile.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct IconTile: View {
    private let systemName: String
    private let foreground: Color
    private let background: Color
    private let baseSize: CGFloat

    public init(
        systemName: String,
        foreground: Color,
        background: Color,
        size: CGFloat = 32
    ) {
        self.systemName = systemName
        self.foreground = foreground
        self.background = background
        self.baseSize = size
    }

    public var body: some View {
        Tile(systemName: systemName, foreground: foreground, background: background, baseSize: baseSize)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}

private struct Tile: View {
    let systemName: String
    let foreground: Color
    let background: Color

    @ScaledMetric private var size: CGFloat

    init(systemName: String, foreground: Color, background: Color, baseSize: CGFloat) {
        self.systemName = systemName
        self.foreground = foreground
        self.background = background
        _size = ScaledMetric(wrappedValue: baseSize)
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(
                background,
                in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}
