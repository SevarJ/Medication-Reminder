//
//  Badge.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct Badge: View {
    private let title: String
    private let systemName: String?
    private let foreground: Color
    private let background: Color

    public init(
        title: String,
        systemName: String? = nil,
        foreground: Color = Color.theme.accentText,
        background: Color = Color.theme.accentTint
    ) {
        self.title = title
        self.systemName = systemName
        self.foreground = foreground
        self.background = background
    }

    public var body: some View {
        HStack(spacing: Spacing.xs) {
            if let systemName {
                Image(systemName: systemName)
                    .imageScale(.small)
            }

            Text(title)
        }
        .font(Font.theme.badge)
        .foregroundStyle(foreground)
        .padding(.horizontal, Spacing.md - 2)
        .padding(.vertical, Spacing.xs + 1)
        .background(background, in: Capsule())
    }
}
