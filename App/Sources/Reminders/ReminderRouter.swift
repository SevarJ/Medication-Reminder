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
    var doseReminder: DoseReminderRequest?
    private(set) var revision = 0
    
    func open(medicationId: UUID, scheduledDate: Date) {
        doseReminder = DoseReminderRequest(medicationId: medicationId, scheduledDate: scheduledDate)
    }
    
    func close() {
        doseReminder = nil
    }
    
    func didClose() {
        revision += 1
    }
}
