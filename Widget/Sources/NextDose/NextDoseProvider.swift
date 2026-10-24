//
//  NextDoseProvider.swift
//  MedoraWidget
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppLocalization
import Foundation
import WidgetKit
import WidgetSnapshot

struct NextDoseProvider: TimelineProvider {
    private let store = SharedDoseStore()

    func placeholder(in context: Context) -> NextDoseEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (NextDoseEntry) -> Void) {
        let entries = makeEntries(from: store.load(), now: .now)

        completion(context.isPreview && entries.first?.dose == nil ? .placeholder : entries[0])
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextDoseEntry>) -> Void) {
        completion(Timeline(entries: makeEntries(from: store.load(), now: .now), policy: .atEnd))
    }

    func makeEntries(from snapshot: DoseSnapshot, now: Date) -> [NextDoseEntry] {
        let language = snapshot.languageCode.flatMap(AppLanguage.init(rawValue:)) ?? .system
        let changes = snapshot.doses(visibleAt: now)
            .flatMap { [$0.dueSoonDate, $0.visibleUntil] }
            .filter { $0 > now }

        return Set([now] + changes).sorted().map { date in
            NextDoseEntry(date: date, dose: snapshot.doses(visibleAt: date).first, language: language)
        }
    }
}
