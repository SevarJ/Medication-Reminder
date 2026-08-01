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

    @ScaledMetric private var size: CGFloat = 30

    public init(systemName: String, foreground: Color, background: Color) {
        self.systemName = systemName
        self.foreground = foreground
        self.background = background
    }

    public var body: some View {
        Image(systemName: systemName)
            .font(
                .system(
                    size: size * 0.55,
                    weight: .medium
                )
            )
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(
                background,
                in: RoundedRectangle(
                    cornerRadius: CornerRadius.tile
                )
            )
    }
}
