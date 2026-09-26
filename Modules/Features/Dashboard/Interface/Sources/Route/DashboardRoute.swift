//
//  DashboardRoute.swift
//  Dashboard
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Foundation

public enum DashboardRoute: Hashable, Identifiable, Sendable {
    case today(reloadToken: Int)
    case medications
    case doseReminder(medicationId: UUID, scheduledDate: Date)

    public var id: Self { self }
}
