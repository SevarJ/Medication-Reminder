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

/// The one strong moment on the Today screen: the dose that is due next, in deep brand green.
struct NextDoseCard: View {
    let dose: ScheduledDose
    let countdown: String
    let onTake: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            HStack(alignment: .firstTextBaseline) {
                Text(L10n.Today.nextDose)
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(Color.theme.onHero.opacity(0.85))
                
                Spacer(minLength: Spacing.sm)
                
                Text(countdown)
                    .font(Font.theme.badge)
                    .foregroundStyle(Color.theme.onHero)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs + 1)
                    .background(Color.theme.onHero.opacity(0.18), in: Capsule())
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(dose.scheduledDate.timeText)
                    .font(Font.theme.display)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(Color.theme.onHero)
                
                Text(dose.medication.name)
                    .font(.system(.title3, weight: .semibold))
                    .foregroundStyle(Color.theme.onHero)
                
                Text(dose.medication.dosage.displayText)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.onHero.opacity(0.85))
            }
            .accessibilityElement(children: .combine)
            
            Button(action: onTake) {
                Label(L10n.Today.takeNow, systemImage: "checkmark")
            }
            .buttonStyle(.heroAction)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .heroCardBackground()
    }
}

struct DayCompleteCard: View {
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 34))
                .foregroundStyle(Color.theme.accent)
                .symbolEffect(.bounce, value: appeared)
            
            Text(L10n.Today.allDone)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Spacer(minLength: 0)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(Color.theme.accentTint)
        .onAppear { appeared = true }
    }
}
