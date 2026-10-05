//
//  MonthTotalsCard.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import AppLocalization
import DesignSystem
import SwiftUI

struct MonthTotalsCard: View {
    let adherence: Double?
    let taken: Int
    let skipped: Int
    let missed: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(
                adherence.map {
                    L10n.History.adherence($0.formatted(.percent.precision(.fractionLength(0)).locale(AppLanguage.current.locale)))
                } ?? L10n.History.noDosesDue
            )
            .font(Font.theme.sectionTitle)
            .foregroundStyle(Color.theme.textPrimary)
            .contentTransition(.numericText())
            
            HStack(spacing: Spacing.sm) {
                Badge(title: "\(taken) \(L10n.History.taken)", systemName: "checkmark")
                Badge(
                    title: "\(skipped) \(L10n.Today.skipped)",
                    systemName: "forward.end.fill",
                    foreground: Color.theme.info,
                    background: Color.theme.infoTint
                )
                Badge(
                    title: "\(missed) \(L10n.Today.missed)",
                    systemName: "exclamationmark",
                    foreground: Color.theme.warning,
                    background: Color.theme.warningTint
                )
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }
}
