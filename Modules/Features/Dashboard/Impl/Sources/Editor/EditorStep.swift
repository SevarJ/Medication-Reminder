//
//  EditorStep.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 06.10.26.
//

import Domain

/// The four things a medication is made of. Adding walks through them in order,
/// editing opens only the one the user wants to change.
enum EditorStep: Int, CaseIterable, Identifiable, Hashable {
    case details
    case schedule
    case duration
    case extras
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .details: L10n.Form.detailsTitle
        case .schedule: L10n.Form.scheduleTitle
        case .duration: L10n.Form.durationTitle
        case .extras: L10n.Form.extrasTitle
        }
    }
    
    var question: String {
        switch self {
        case .details: L10n.Form.detailsQuestion
        case .schedule: L10n.Form.scheduleQuestion
        case .duration: L10n.Form.durationQuestion
        case .extras: L10n.Form.extrasQuestion
        }
    }
    
    var systemImage: String {
        switch self {
        case .details: "pills.fill"
        case .schedule: "clock.fill"
        case .duration: "calendar"
        case .extras: "shippingbox.fill"
        }
    }
}

extension DosageUnit {
    /// How much the plus and minus buttons change the amount.
    var stepSize: Double {
        switch self {
        case .mg: 50
        case .ml: 0.5
        case .tablet: 0.5
        case .drop: 1
        }
    }
}
