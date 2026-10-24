//
//  NextDoseEntry.swift
//  MedoraWidget
//
//  Created by Sevar Jafarli on 25.10.26.
//

import AppLocalization
import Foundation
import WidgetKit
import WidgetSnapshot

struct NextDoseEntry: TimelineEntry {
    let date: Date
    let dose: UpcomingDoseEntry?
    let language: AppLanguage

    static var placeholder: NextDoseEntry {
        let now = Date.now

        return NextDoseEntry(
            date: now,
            dose: UpcomingDoseEntry(
                medicationId: UUID(),
                name: "Vitamin D",
                detail: "10 drops",
                date: now.addingTimeInterval(3600),
                visibleUntil: now.addingTimeInterval(5400)
            ),
            language: .current
        )
    }
}
