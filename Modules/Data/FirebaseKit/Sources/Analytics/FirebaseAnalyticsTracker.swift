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
        case .introductionCompleted: "introduction_completed"
        case .signedIn: AnalyticsEventLogin
        case .notificationPromptAnswered: "notification_prompt_answered"
        case .paywallShown: "paywall_shown"
        case .purchaseFinished: "purchase_result"
        case .purchasesRestored: "restore_result"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .doseLogged(let status): ["status": status.analyticsValue]
        case .signedIn: [AnalyticsParameterMethod: "google"]
        case .notificationPromptAnswered(let answer): ["answer": answer.analyticsValue]
        case .purchaseFinished(let outcome): outcome.analyticsParameters
        case .purchasesRestored(let outcome): ["result": outcome.analyticsValue]
        case .medicationAdded, .medicationDeleted, .reminderSnoozed, .introductionCompleted, .paywallShown: nil
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

private extension NotificationPromptAnswer {
    var analyticsValue: String {
        switch self {
        case .allowed: "allowed"
        case .denied: "denied"
        case .postponed: "postponed"
        }
    }
}

private extension PurchaseOutcome {
    var analyticsParameters: [String: Any] {
        switch self {
        case .purchased(let productID): ["result": "purchased", "product_id": productID]
        case .pending: ["result": "pending"]
        case .cancelled: ["result": "cancelled"]
        case .failed: ["result": "failed"]
        }
    }
}

private extension RestoreOutcome {
    var analyticsValue: String {
        switch self {
        case .restored: "restored"
        case .nothingToRestore: "nothing_to_restore"
        case .failed: "failed"
        }
    }
}
