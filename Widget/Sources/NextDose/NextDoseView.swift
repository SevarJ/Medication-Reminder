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

    @Environment(\.widgetFamily) private var family

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
        .containerBackground(isLockScreen ? Color.clear : Color.theme.hero, for: .widget)
        .environment(\.locale, entry.language.locale)
    }

    private var isLockScreen: Bool {
        family == .accessoryRectangular
    }

    @ViewBuilder
    private func content(for dose: UpcomingDoseEntry) -> some View {
        if isLockScreen {
            lockScreenContent(for: dose)
        }
        else {
            smallContent(for: dose)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if isLockScreen {
            lockScreenEmptyState
        }
        else {
            smallEmptyState
        }
    }

    private func lockScreenContent(for dose: UpcomingDoseEntry) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(formattedTime(dose.date))
                    .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
                    .layoutPriority(1)

                Spacer(minLength: 0)

                Text(dayLabel(for: dose.date))
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .widgetAccentable()

            Text(dose.name)
                .font(.system(.subheadline, weight: .semibold))
                .lineLimit(1)

            Text(dose.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }

    private var lockScreenEmptyState: some View {
        Label(L10n.noDoses(entry.language), systemImage: "checkmark.circle.fill")
            .font(.system(.headline, weight: .semibold))
            .lineLimit(2)
            .frame(maxHeight: .infinity)
            .accessibilityElement(children: .combine)
    }

    private func smallContent(for dose: UpcomingDoseEntry) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(dayLabel(for: dose.date))
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(Color.theme.onHero.opacity(0.8))
                .lineLimit(1)

            Spacer(minLength: 0)

            Text(formattedTime(dose.date))
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

    private var smallEmptyState: some View {
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

    private func formattedTime(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)

        return String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
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
