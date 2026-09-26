//
//  DoseReminderRoute.swift
//  MedReminder
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Foundation

struct DoseReminderRoute: Identifiable {
    let id = UUID()
    let medicationId: UUID
    let scheduledDate: Date
}
