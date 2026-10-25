//
//  NotificationPrimingView.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import SwiftUI

struct NotificationPrimingView: View {
    private let onAllow: () -> Void
    private let onNotNow: () -> Void
    
    init(onAllow: @escaping () -> Void, onNotNow: @escaping () -> Void) {
        self.onAllow = onAllow
        self.onNotNow = onNotNow
    }
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    SampleNotification()
                        .padding(.top, Spacing.xxl)
                    
                    VStack(spacing: Spacing.md) {
                        Text(L10n.Priming.title)
                            .font(Font.theme.screenTitle)
                            .foregroundStyle(Color.theme.textPrimary)
                        
                        Text(L10n.Priming.message)
                            .font(.system(.title3))
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                    .multilineTextAlignment(.center)
                    .accessibilityElement(children: .combine)
                }
                .frame(maxWidth: .infinity)
            }
            .defaultScrollAnchor(UnitPoint(x: 0.5, y: 0.3))
            .scrollBounceBehavior(.basedOnSize)
            
            VStack(spacing: Spacing.md) {
                Button(L10n.Priming.allow, action: onAllow)
                    .buttonStyle(.primaryAction)
                
                Button(L10n.Priming.notNow, action: onNotNow)
                    .buttonStyle(.secondaryAction)
            }
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

private struct SampleNotification: View {
    @ScaledMetric private var iconSize: CGFloat = 38
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: "pills.fill")
                .font(.system(size: iconSize * 0.5, weight: .semibold))
                .foregroundStyle(Color.theme.onHero)
                .frame(width: iconSize, height: iconSize)
                .background(Color.theme.hero, in: RoundedRectangle(cornerRadius: iconSize * 0.24, style: .continuous))
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(verbatim: "Medora")
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(Color.theme.textPrimary)
                    
                    Spacer()
                    
                    Text(L10n.Priming.sampleTime)
                        .font(.system(.subheadline))
                        .foregroundStyle(Color.theme.textSecondary)
                }
                
                Text(L10n.Priming.sampleTitle)
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(L10n.Priming.sampleBody)
                    .font(.system(.body))
                    .foregroundStyle(Color.theme.textPrimary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.theme.surface, in: RoundedRectangle(cornerRadius: CornerRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: CornerRadius.card, style: .continuous)
                .stroke(Color.theme.separator, lineWidth: 0.5)
        }
        .accessibilityHidden(true)
    }
}
