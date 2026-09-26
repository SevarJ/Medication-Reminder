//
//  DoseRow.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppFormatters
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
                    .foregroundStyle(state == .taken ? Color.theme.textSecondary : Color.theme.textPrimary)
                    .strikethrough(state == .taken, color: Color.theme.textSecondary)
                
                Text(subtitle)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(state == .missed ? Color.theme.danger : Color.theme.textSecondary)
            }
            
            Spacer(minLength: Spacing.sm)
            
            trailing
        }
        .padding(Spacing.lg)
        .opacity(state == .skipped ? 0.6 : 1)
        .animation(.spring(duration: 0.35), value: state)
        .sensoryFeedback(trigger: state) { _, newValue in
            newValue == .taken ? .success : nil
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: onTake) {
                Label(
                    state == .taken ? L10n.Today.markNotTaken : L10n.Today.take,
                    systemImage: state == .taken ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(Color.theme.accent)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if state != .taken {
                Button(action: onSkip) {
                    Label(
                        state == .skipped ? L10n.Today.markNotTaken : L10n.Today.skip,
                        systemImage: state == .skipped ? "arrow.uturn.backward" : "forward.end"
                    )
                }
                .tint(Color.theme.textSecondary)
            }
        }
    }
    
    private var checkbox: some View {
        Button(action: onTake) {
            Image(systemName: state == .taken ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 28))
                .foregroundStyle(state == .taken ? Color.theme.accent : Color.theme.textSecondary)
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, value: state == .taken)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(state == .taken ? L10n.Today.markNotTaken : L10n.Today.markTaken)
    }
    
    @ViewBuilder private var trailing: some View {
        switch state {
        case .taken:
            if let recordedAt = dose.log?.recordedAt {
                Badge(title: L10n.Today.takenAt(recordedAt.timeText))
                    .transition(.scale.combined(with: .opacity))
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
