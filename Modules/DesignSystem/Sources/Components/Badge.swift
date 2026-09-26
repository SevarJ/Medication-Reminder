//
//  Badge.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct Badge: View {
    private let title: String
    private let foreground: Color
    private let background: Color

    public init(
        title: String,
        foreground: Color = Color.theme.accent,
        background: Color = Color.theme.accentTint
    ) {
        self.title = title
        self.foreground = foreground
        self.background = background
    }

    public var body: some View {
        Text(title)
            .font(Font.theme.badge)
            .foregroundStyle(foreground)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                background,
                in: RoundedRectangle(cornerRadius: CornerRadius.badge)
            )
    }
}
