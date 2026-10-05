//
//  ActionButtonStyles.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 05.10.26.
//

import SwiftUI

/// The one main action on a screen: a full-width solid capsule in the deep brand green.
public struct PrimaryActionButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ActionLabel(
            configuration: configuration,
            foreground: Color.theme.onHero,
            background: Color.theme.hero
        )
    }
}

/// Same shape as the primary action, for a button that sits on a green hero card.
public struct HeroActionButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ActionLabel(
            configuration: configuration,
            foreground: Color.theme.hero,
            background: Color.white
        )
    }
}

/// A quiet alternative that still reads as a button: neutral fill, primary text.
public struct SecondaryActionButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        ActionLabel(
            configuration: configuration,
            foreground: Color.theme.textPrimary,
            background: Color.theme.fill,
            height: Size.minTarget + 6
        )
    }
}

public extension ButtonStyle where Self == PrimaryActionButtonStyle {
    static var primaryAction: PrimaryActionButtonStyle { PrimaryActionButtonStyle() }
}

public extension ButtonStyle where Self == HeroActionButtonStyle {
    static var heroAction: HeroActionButtonStyle { HeroActionButtonStyle() }
}

public extension ButtonStyle where Self == SecondaryActionButtonStyle {
    static var secondaryAction: SecondaryActionButtonStyle { SecondaryActionButtonStyle() }
}

private struct ActionLabel: View {
    let configuration: ButtonStyleConfiguration
    let foreground: Color
    let background: Color
    var height: CGFloat = Size.primaryButton

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.system(.headline, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: height)
            .padding(.horizontal, Spacing.lg)
            .background(background, in: Capsule())
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}
