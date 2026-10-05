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
            glyph
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(dose.medication.name)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text("\(dose.scheduledDate.timeText) · \(dose.medication.dosage.displayText)")
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                
                if state == .missed {
                    Text(L10n.Today.missed)
                        .font(Font.theme.badge)
                        .foregroundStyle(Color.theme.warning)
                }
            }
            .opacity(state == .skipped ? 0.65 : 1)
            
            Spacer(minLength: Spacing.sm)
            
            trailing
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.lg)
        .frame(minHeight: 72)
        .contentShape(Rectangle())
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
            .tint(Color.theme.hero)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if state != .taken {
                Button(action: onSkip) {
                    Label(
                        state == .skipped ? L10n.Today.markNotTaken : L10n.Today.skip,
                        systemImage: state == .skipped ? "arrow.uturn.backward" : "forward.end"
                    )
                }
                .tint(Color.theme.info)
            }
        }
    }
    
    @ViewBuilder private var glyph: some View {
        switch state {
        case .taken:
            IconTile(systemName: "checkmark", foreground: Color.theme.onHero, background: Color.theme.accent, size: 40)
        case .missed:
            IconTile(systemName: "exclamationmark", foreground: Color.theme.warning, background: Color.theme.warningTint, size: 40)
        case .skipped:
            IconTile(systemName: "forward.end.fill", foreground: Color.theme.info, background: Color.theme.infoTint, size: 40)
        case .pending:
            IconTile(systemName: "pills.fill", foreground: Color.theme.accentText, background: Color.theme.accentTint, size: 40)
        }
    }
    
    @ViewBuilder private var trailing: some View {
        switch state {
        case .taken:
            Button(action: onTake) {
                Text(dose.log.map { L10n.Today.takenAt($0.recordedAt.timeText) } ?? "")
                    .font(Font.theme.badge)
                    .foregroundStyle(Color.theme.accentText)
                    .frame(minHeight: Size.minTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Today.markNotTaken)
        case .skipped:
            Button(action: onSkip) {
                Text(L10n.Today.skipped)
                    .font(Font.theme.badge)
                    .foregroundStyle(Color.theme.info)
                    .frame(minHeight: Size.minTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Today.markNotTaken)
        case .pending, .missed:
            HStack(spacing: 0) {
                Button(action: onTake) {
                    Text(L10n.Today.take)
                        .font(.system(.subheadline, weight: .semibold))
                        .lineLimit(1)
                        .fixedSize()
                        .foregroundStyle(Color.theme.accentText)
                        .padding(.horizontal, Spacing.lg)
                        .frame(minHeight: Size.minTarget - 4)
                        .background(Color.theme.accentTint, in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Menu {
                    Button(action: onSkip) {
                        Label(L10n.Today.skip, systemImage: "forward.end")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(Color.theme.textSecondary)
                        .frame(width: Size.minTarget - 8, height: Size.minTarget)
                        .contentShape(Rectangle())
                }
            }
        }
    }
}
