//
//  AnalyticsEvent.swift
//  Domain
//
//  Created by Sevar Jafarli on 25.10.26.
//

public enum AnalyticsEvent: Sendable, Equatable {
    case medicationAdded
    case medicationDeleted
    case doseLogged(DoseStatus)
    case reminderSnoozed
    case introductionCompleted
    case signedIn
    case notificationPromptAnswered(NotificationPromptAnswer)
    case paywallShown
    case purchaseFinished(PurchaseOutcome)
    case purchasesRestored(RestoreOutcome)
}
