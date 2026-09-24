//
//  NotificationPrimingView.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import SwiftUI

public struct NotificationPrimingView: View {
    private let onAllow: () -> Void
    private let onNotNow: () -> Void
    
    public init(onAllow: @escaping () -> Void, onNotNow: @escaping () -> Void) {
        self.onAllow = onAllow
        self.onNotNow = onNotNow
    }
    
    public var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.theme.accent)
                .padding(Spacing.xxl)
                .background(Color.theme.accentTint, in: Circle())
            
            VStack(spacing: Spacing.md) {
                Text("Never Miss a Dose")
                    .font(Font.theme.screenTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("MedReminder uses notifications to remind you when it's time to take your medication. You can mark doses as taken or snooze them right from the notification.")
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: Spacing.md) {
                Button(action: onAllow) {
                    Text("Allow Notifications")
                        .font(Font.theme.rowTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.theme.accent)
                
                Button("Not Now", action: onNotNow)
                    .font(Font.theme.rowSubtitle)
                    .tint(Color.theme.textSecondary)
            }
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}
