//
//  ReminderRouter.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation
import MedicationFeature
import Observation

@MainActor
@Observable
final class ReminderRouter {
    var doseReminder: DoseReminderViewModel?
    private(set) var revision = 0
    
    func open(medicationId: UUID, scheduledDate: Date) {
        doseReminder = AppComposition.makeDoseReminderViewModel(
            medicationId: medicationId,
            scheduledDate: scheduledDate
        )
    }
    
    func close() {
        doseReminder = nil
    }
    
    func didClose() {
        revision += 1
    }
}
