//
//  NextDoseView.swift
//  MedoraWidget
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppLocalization
import DesignSystem
import SwiftUI
import WidgetKit
import WidgetSnapshot

struct NextDoseView: View {
    let entry: NextDoseEntry

    var body: some View {
        Group {
            if let dose = entry.dose {
                content(for: dose)
                    .widgetURL(link(for: dose))
            }
            else {
                emptyState
                    .widgetURL(TodayLink.url)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(Color.theme.hero, for: .widget)
        .environment(\.locale, entry.language.locale)
    }

    private func content(for dose: UpcomingDoseEntry) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(dayLabel(for: dose.date))
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(Color.theme.onHero.opacity(0.8))
                .lineLimit(1)

            Spacer(minLength: 0)

            Text(dose.date.formatted(.dateTime.hour().minute().locale(entry.language.locale)))
                .font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .foregroundStyle(Color.theme.onHero)

            Text(dose.name)
                .font(.system(.headline, weight: .semibold))
                .foregroundStyle(Color.theme.onHero)
                .lineLimit(2)

            Text(dose.detail)
                .font(.caption)
                .foregroundStyle(Color.theme.onHero.opacity(0.85))
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(Color.theme.onHero)

            Spacer(minLength: 0)

            Text(L10n.noDoses(entry.language))
                .font(.system(.headline, weight: .semibold))
                .foregroundStyle(Color.theme.onHero)
                .lineLimit(3)
        }
        .accessibilityElement(children: .combine)
    }

    private func link(for dose: UpcomingDoseEntry) -> URL? {
        dose.isDueSoon(at: entry.date)
            ? DoseLink(medicationId: dose.medicationId, scheduledDate: dose.date).url
            : TodayLink.url
    }

    private func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDate(date, inSameDayAs: entry.date) {
            return L10n.nextDose(entry.language)
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: entry.date),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return L10n.tomorrow(entry.language)
        }

        return date.formatted(.dateTime.weekday(.wide).locale(entry.language.locale))
    }
}
