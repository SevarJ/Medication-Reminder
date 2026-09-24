//
//  DoseRow.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import Domain
import SwiftUI

struct DoseRow: View {
    let dose: ScheduledDose
    let state: DoseState
    let onTake: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            checkbox
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(dose.medication.name)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(subtitle)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(state == .missed ? Color.theme.danger : Color.theme.textSecondary)
            }
            
            Spacer(minLength: Spacing.sm)
            
            trailing
        }
        .padding(Spacing.lg)
        .opacity(state == .skipped ? 0.6 : 1)
    }
    
    private var checkbox: some View {
        Button(action: onTake) {
            Image(systemName: state == .taken ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 26))
                .foregroundStyle(state == .taken ? Color.theme.accent : Color.theme.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(state == .taken ? L10n.Today.markNotTaken : L10n.Today.markTaken)
    }
    
    @ViewBuilder private var trailing: some View {
        switch state {
        case .taken:
            if let recordedAt = dose.log?.recordedAt {
                Badge(title: L10n.Today.takenAt(recordedAt.timeText))
            }
        case .skipped, .pending, .missed:
            Button(action: onSkip) {
                Text(state == .skipped ? L10n.Today.skipped : L10n.Today.skip)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.badge)
                            .stroke(Color.theme.separator, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var subtitle: String {
        let details = "\(dose.scheduledDate.timeText) · \(dose.medication.dosage.displayText)"
        
        return state == .missed ? "\(details) · \(L10n.Today.missed)" : details
    }
}
