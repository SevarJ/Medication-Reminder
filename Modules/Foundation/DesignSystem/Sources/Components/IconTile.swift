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

    @ScaledMetric private var size: CGFloat

    public init(
        systemName: String,
        foreground: Color,
        background: Color,
        size: CGFloat = 32
    ) {
        self.systemName = systemName
        self.foreground = foreground
        self.background = background
        _size = ScaledMetric(wrappedValue: size)
    }

    public var body: some View {
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
