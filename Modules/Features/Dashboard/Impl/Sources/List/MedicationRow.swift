//
//  MedicationRow.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppFormatters
import DesignSystem
import Domain
import SwiftUI

struct MedicationRow: View {
    let medication: Medication
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let layout = isLarge
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.md))
        
        return layout {
            IconTile(
                systemName: "pills.fill",
                foreground: medication.isActive ? Color.theme.accentText : Color.theme.textSecondary,
                background: medication.isActive ? Color.theme.accentTint : Color.theme.fill,
                size: 44
            )
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(medication.name)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text("\(medication.dosage.displayText) · \(medication.schedule.recurrence.displayText)")
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                
                Text(medication.schedule.times.map(\.displayText).joined(separator: "  ·  "))
                    .font(.system(.footnote, design: .rounded, weight: .semibold).monospacedDigit())
                    .foregroundStyle(medication.isActive ? Color.theme.accentText : Color.theme.textSecondary)
                    .padding(.top, 2)
            }
            .opacity(medication.isActive ? 1 : 0.65)
            
            if !isLarge {
                Spacer(minLength: Spacing.sm)
            }
            
            if !medication.isActive {
                Badge(
                    title: L10n.List.paused,
                    systemName: "pause.fill",
                    foreground: Color.theme.textSecondary,
                    background: Color.theme.fill
                )
            }
            
            if !isLarge {
                Image(systemName: "chevron.right")
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(Color.theme.textSecondary.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.lg)
        .frame(minHeight: 76)
        .contentShape(Rectangle())
    }
}
