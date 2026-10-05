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
            Spacer()
            
            HeroGlyph(systemName: "bell.badge.fill")
            
            VStack(spacing: Spacing.md) {
                Text(L10n.Priming.title)
                    .font(Font.theme.screenTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(L10n.Priming.message)
                    .font(.system(.body))
                    .foregroundStyle(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
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
