//
//  MedicationRow.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import DesignSystem
import Domain
import SwiftUI

struct MedicationRow: View {
    let medication: Medication
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            IconTile(
                systemName: "pills.fill",
                foreground: medication.isActive ? Color.theme.accent : Color.theme.textSecondary,
                background: medication.isActive ? Color.theme.accentTint : Color.theme.separator
            )
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(medication.name)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text("\(medication.dosage.displayText) · \(medication.schedule.recurrence.displayText)")
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                
                HStack(spacing: Spacing.xs) {
                    ForEach(medication.schedule.times) { time in
                        Badge(
                            title: time.displayText,
                            foreground: color(for: time),
                            background: Color.theme.accentTint
                        )
                    }
                }
            }
            .opacity(medication.isActive ? 1 : 0.6)
            
            Spacer(minLength: Spacing.sm)
            
            if !medication.isActive {
                Badge(
                    title: "Paused",
                    foreground: Color.theme.textSecondary,
                    background: Color.theme.separator
                )
            }
            
            Image(systemName: "chevron.right")
                .font(Font.theme.caption)
                .foregroundStyle(Color.theme.textSecondary)
        }
        .padding(Spacing.lg)
        .contentShape(Rectangle())
    }
    
    private func color(for time: MedTime) -> Color {
        time.hour < 12 ? Color.theme.morning : Color.theme.evening
    }
}
