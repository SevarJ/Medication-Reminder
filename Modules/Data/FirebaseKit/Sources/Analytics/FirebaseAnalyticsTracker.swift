//
//  FirebaseAnalyticsTracker.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain
internal import FirebaseAnalytics

struct FirebaseAnalyticsTracker: AnalyticsTracking {
    func track(_ event: AnalyticsEvent) async {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}

private extension AnalyticsEvent {
    var name: String {
        switch self {
        case .medicationAdded: "medication_added"
        case .medicationDeleted: "medication_deleted"
        case .doseLogged: "dose_logged"
        case .reminderSnoozed: "reminder_snoozed"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .doseLogged(let status): ["status": status.analyticsValue]
        case .medicationAdded, .medicationDeleted, .reminderSnoozed: nil
        }
    }
}

private extension DoseStatus {
    var analyticsValue: String {
        switch self {
        case .taken: "taken"
        case .skipped: "skipped"
        }
    }
}
