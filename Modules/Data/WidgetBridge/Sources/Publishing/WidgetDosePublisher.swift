//
//  WidgetDosePublisher.swift
//  WidgetBridge
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppFormatters
import AppLocalization
import Domain
import Foundation
import WidgetSnapshot

struct WidgetDosePublisher: UpcomingDosePublishing {
    private let store: SharedDoseStore
    private let language: @Sendable () -> AppLanguage
    private let reloadWidgets: @Sendable () -> Void

    init(
        store: SharedDoseStore,
        language: @escaping @Sendable () -> AppLanguage = { .current },
        reloadWidgets: @escaping @Sendable () -> Void
    ) {
        self.store = store
        self.language = language
        self.reloadWidgets = reloadWidgets
    }

    func publish(_ doses: [ScheduledDose]) async {
        let entries = doses.map { dose in
            UpcomingDoseEntry(
                medicationId: dose.medication.id,
                name: dose.medication.name,
                detail: dose.medication.doseText,
                date: dose.scheduledDate,
                visibleUntil: dose.scheduledDate.addingTimeInterval(PublishUpcomingDosesUseCase.overdueWindow)
            )
        }
        let snapshot = DoseSnapshot(doses: entries, languageCode: language().code)

        guard snapshot != store.load() else { return }

        store.save(snapshot)
        reloadWidgets()
    }

    func clear() async {
        store.clear()
        reloadWidgets()
    }
}
