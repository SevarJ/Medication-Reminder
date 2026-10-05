//
//  HeroGlyph.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 05.10.26.
//

import SwiftUI

/// A large rounded-square symbol in the deep brand green, used on welcome and permission screens.
public struct HeroGlyph: View {
    private let systemName: String

    @ScaledMetric private var size: CGFloat = 112

    public init(systemName: String) {
        self.systemName = systemName
    }

    public var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.46, weight: .semibold))
            .foregroundStyle(Color.theme.onHero)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [Color.theme.hero, Color.theme.heroDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
            )
            .shadow(color: Color.theme.hero.opacity(0.28), radius: 24, y: 12)
            .accessibilityHidden(true)
    }
}
