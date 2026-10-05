//
//  HistoryDoseRow.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import AppFormatters
import DesignSystem
import Domain
import SwiftUI

/// A dose in the history. Unlike the rows on the Today screen it only reports what happened.
struct HistoryDoseRow: View {
    let dose: ScheduledDose
    let state: DoseState
    let onOpen: () -> Void
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.md))
        
        return layout {
            Button(action: onOpen) {
                layout {
                    glyph
                    
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(dose.medication.name)
                            .font(Font.theme.rowTitle)
                            .foregroundStyle(Color.theme.textPrimary)
                        
                        Text("\(dose.scheduledDate.timeText) · \(dose.medication.dosage.displayText)")
                            .font(Font.theme.rowSubtitle)
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            status
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.lg)
        .frame(minHeight: 72)
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
    
    @ViewBuilder private var status: some View {
        switch state {
        case .taken:
            Text(dose.log.map { L10n.Today.takenAt($0.recordedAt.timeText) } ?? "")
                .font(Font.theme.badge)
                .foregroundStyle(Color.theme.accentText)
        case .skipped:
            Text(L10n.Today.skipped)
                .font(Font.theme.badge)
                .foregroundStyle(Color.theme.info)
        case .missed:
            Text(L10n.Today.missed)
                .font(Font.theme.badge)
                .foregroundStyle(Color.theme.warning)
        case .pending:
            Text(L10n.History.upcoming)
                .font(Font.theme.badge)
                .foregroundStyle(Color.theme.textSecondary)
        }
    }
}
