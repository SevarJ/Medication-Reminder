//
//  WeekStrip.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import Domain
import SwiftUI

struct WeekStrip: View {
    let days: [DoseDaySummary]
    let isSelected: (Date) -> Bool
    let onSelect: (Date) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                Button {
                    onSelect(day.date)
                } label: {
                    dayCell(day, isSelected: isSelected(day.date))
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel(accessibilityText(for: day))
                .accessibilityAddTraits(isSelected(day.date) ? .isSelected : [])
            }
        }
        .sensoryFeedback(.selection, trigger: days.first(where: { isSelected($0.date) })?.date)
    }
    
    private func dayCell(_ day: DoseDaySummary, isSelected: Bool) -> some View {
        VStack(spacing: Spacing.xs) {
            Text(day.date.formatted(.dateTime.weekday(.abbreviated).locale(AppLanguage.current.locale)))
                .font(Font.theme.caption)
                .foregroundStyle(isSelected ? Color.theme.accent : Color.theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            ZStack {
                Circle()
                    .fill(isSelected ? Color.theme.accent : Color.clear)
                
                if day.doses.isEmpty {
                    Circle()
                        .stroke(Color.theme.separator, lineWidth: 3)
                        .padding(1.5)
                }
                else {
                    ProgressRing(
                        progress: day.adherence,
                        lineWidth: 3,
                        tint: isSelected ? Color.theme.surface : Color.theme.accent
                    )
                }
                
                Text(day.date.formatted(.dateTime.day().locale(AppLanguage.current.locale)))
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.theme.surface : Color.theme.textPrimary)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.vertical, Spacing.xs)
        .contentShape(Rectangle())
        .animation(.spring(duration: 0.3), value: isSelected)
    }
    
    private func accessibilityText(for day: DoseDaySummary) -> String {
        let date = day.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(AppLanguage.current.locale))
        
        return day.doses.isEmpty ? date : "\(date), \(day.takenCount)/\(day.doses.count)"
    }
}
