//
//  MonthGrid.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import AppLocalization
import DesignSystem
import Domain
import SwiftUI

struct MonthGrid: View {
    let weekdayHeaders: [String]
    let days: [Date?]
    let summary: (Date) -> DoseDaySummary?
    let outcome: (Date) -> DayOutcome
    let isSelected: (Date) -> Bool
    let isEnabled: (Date) -> Bool
    let onSelect: (Date) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(weekdayHeaders.enumerated()), id: \.offset) { _, header in
                    Text(header)
                        .font(Font.theme.caption)
                        .foregroundStyle(Color.theme.textSecondary)
                        .accessibilityHidden(true)
                }
            }
            
            LazyVGrid(columns: columns, spacing: Spacing.xs) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    if let day {
                        Button {
                            onSelect(day)
                        } label: {
                            cell(for: day)
                        }
                        .buttonStyle(.plain)
                        .disabled(!isEnabled(day))
                        .accessibilityLabel(accessibilityText(for: day))
                        .accessibilityAddTraits(isSelected(day) ? .isSelected : [])
                    }
                    else {
                        Color.clear
                            .frame(height: Size.minTarget)
                    }
                }
            }
        }
        // Like the week strip, the grid stays a grid at large text sizes. VoiceOver reads each day in full.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .sensoryFeedback(.selection, trigger: days.compactMap { $0 }.first(where: isSelected))
    }
    
    private func cell(for day: Date) -> some View {
        let selected = isSelected(day)
        let outcome = outcome(day)
        
        return ZStack {
            marker(for: outcome, adherence: summary(day)?.adherence ?? 0)
            
            Text(day.formatted(.dateTime.day().locale(AppLanguage.current.locale)))
                .font(.system(.subheadline, weight: selected ? .bold : .medium))
                .foregroundStyle(isEnabled(day) ? numberColor(for: outcome) : Color.theme.textSecondary.opacity(0.5))
        }
        .frame(width: Size.minTarget, height: Size.minTarget)
        .overlay {
            if selected {
                Circle()
                    .stroke(Color.theme.hero, lineWidth: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .animation(.spring(duration: 0.3), value: selected)
    }
    
    @ViewBuilder
    private func marker(for outcome: DayOutcome, adherence: Double) -> some View {
        switch outcome {
        case .complete:
            Circle()
                .fill(Color.theme.accent)
                .padding(4)
        case .partial:
            ProgressRing(progress: adherence, lineWidth: 4)
                .padding(2)
        case .missed:
            Circle()
                .fill(Color.theme.warningTint)
                .padding(4)
        case .upcoming:
            Circle()
                .stroke(Color.theme.fill, lineWidth: 3)
                .padding(5.5)
        case .none:
            EmptyView()
        }
    }
    
    private func numberColor(for outcome: DayOutcome) -> Color {
        switch outcome {
        case .complete: Color.theme.onHero
        case .missed: Color.theme.warning
        case .partial, .upcoming, .none: Color.theme.textPrimary
        }
    }
    
    private func accessibilityText(for day: Date) -> String {
        let date = day.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(AppLanguage.current.locale))
        
        guard let summary = summary(day) else { return date }
        
        return "\(date), \(summary.takenCount)/\(summary.doses.count)"
    }
}
