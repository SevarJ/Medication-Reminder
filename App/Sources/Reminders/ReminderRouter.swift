//
//  ReminderRouter.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Dashboard
import Foundation
import Observation

@MainActor
@Observable
final class ReminderRouter {
    var doseReminder: DashboardRoute?
    private(set) var revision = 0
    
    func open(medicationId: UUID, scheduledDate: Date) {
        doseReminder = .doseReminder(medicationId: medicationId, scheduledDate: scheduledDate)
    }
    
    func didClose() {
        revision += 1
    }
}
