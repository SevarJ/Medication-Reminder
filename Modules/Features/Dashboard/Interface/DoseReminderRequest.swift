//
//  DoseReminderRequest.swift
//  Dashboard
//
//  Created by Sevar Jafarli on 26.09.26.
//

import Foundation

public struct DoseReminderRequest: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let medicationId: UUID
    public let scheduledDate: Date

    public init(medicationId: UUID, scheduledDate: Date) {
        self.id = UUID()
        self.medicationId = medicationId
        self.scheduledDate = scheduledDate
    }
}
