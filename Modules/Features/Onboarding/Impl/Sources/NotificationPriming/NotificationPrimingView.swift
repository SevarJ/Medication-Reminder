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
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.theme.accent)
                .padding(Spacing.xxl)
                .background(Color.theme.accentTint, in: Circle())
            
            VStack(spacing: Spacing.md) {
                Text(L10n.Priming.title)
                    .font(Font.theme.screenTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(L10n.Priming.message)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: Spacing.md) {
                Button(action: onAllow) {
                    Text(L10n.Priming.allow)
                        .font(Font.theme.rowTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.theme.accent)
                
                Button(L10n.Priming.notNow, action: onNotNow)
                    .font(Font.theme.rowSubtitle)
                    .tint(Color.theme.textSecondary)
            }
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}
