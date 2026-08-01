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
        .background(
            Color.theme.surface,
            in: RoundedRectangle(cornerRadius: CornerRadius.card)
        )
        .padding(.horizontal, Spacing.lg)
    }
}
