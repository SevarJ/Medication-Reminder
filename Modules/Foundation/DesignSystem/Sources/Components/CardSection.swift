//
//  CardSection.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct CardSection<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .cardSurface()
        .padding(.horizontal, Spacing.lg)
    }
}

public extension View {
    /// The standard grouped surface: a continuous rounded rectangle on the card colour.
    func cardSurface(_ fill: Color = Color.theme.surface) -> some View {
        background(fill, in: RoundedRectangle(cornerRadius: CornerRadius.card, style: .continuous))
    }
}
