//
//  HeroCard.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 06.10.26.
//

import SwiftUI

public extension View {
    /// The deep green card used for the one strong moment on a screen. White content sits on top.
    func heroCardBackground() -> some View {
        background {
            // The pill is an overlay, so it never makes the card taller than its content.
            LinearGradient(
                colors: [Color.theme.hero, Color.theme.heroDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(alignment: .topTrailing) {
                Image(systemName: "pills.fill")
                    .font(.system(size: 150))
                    .foregroundStyle(Color.theme.onHero.opacity(0.07))
                    .rotationEffect(.degrees(-18))
                    .offset(x: 30, y: 54)
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card + 6, style: .continuous))
        }
    }
}
