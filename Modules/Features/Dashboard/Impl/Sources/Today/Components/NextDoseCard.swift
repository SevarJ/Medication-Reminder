//
//  NextDoseCard.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppFormatters
import DesignSystem
import Domain
import SwiftUI

struct NextDoseCard: View {
    let dose: ScheduledDose
    let countdown: String
    let onTake: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Label(L10n.Today.nextDose, systemImage: "bell.badge.fill")
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(Color.theme.accent)
                
                Spacer(minLength: Spacing.sm)
                
                Text(countdown)
                    .font(Font.theme.caption)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            
            HStack(spacing: Spacing.md) {
                IconTile(
                    systemName: "pills.fill",
                    foreground: Color.theme.surface,
                    background: Color.theme.accent
                )
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(dose.medication.name)
                        .font(.system(.title3, weight: .bold))
                        .foregroundStyle(Color.theme.textPrimary)
                    
                    Text("\(dose.scheduledDate.timeText) · \(dose.medication.dosage.displayText)")
                        .font(Font.theme.rowSubtitle)
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
            
            Button(action: onTake) {
                Label(L10n.Today.takeNow, systemImage: "checkmark")
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.surface)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Color.theme.accent, in: RoundedRectangle(cornerRadius: CornerRadius.card))
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.lg)
        .background(Color.theme.accentTint, in: RoundedRectangle(cornerRadius: CornerRadius.card))
    }
}

struct DayCompleteCard: View {
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 32))
                .foregroundStyle(Color.theme.accent)
                .symbolEffect(.bounce, value: appeared)
            
            Text(L10n.Today.allDone)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Spacer(minLength: 0)
        }
        .padding(Spacing.lg)
        .background(Color.theme.accentTint, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .onAppear { appeared = true }
    }
}
