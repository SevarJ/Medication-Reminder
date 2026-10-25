//
//  MedicationFilter.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import Domain

enum MedicationFilter: CaseIterable, Identifiable {
    case active
    case paused

    var id: Self { self }

    var title: String {
        switch self {
        case .active: L10n.List.activeFilter
        case .paused: L10n.List.pausedFilter
        }
    }

    var emptyTitle: String {
        switch self {
        case .active: L10n.List.noActiveTitle
        case .paused: L10n.List.noPausedTitle
        }
    }

    var emptyMessage: String {
        switch self {
        case .active: L10n.List.noActiveMessage
        case .paused: L10n.List.noPausedMessage
        }
    }

    func includes(_ medication: Medication) -> Bool {
        switch self {
        case .active: medication.isActive
        case .paused: !medication.isActive
        }
    }
}
