//
//  DoseLogEntity.swift
//  Persistence
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation
import SwiftData

@Model
final class DoseLogEntity {
    @Attribute(.unique) var id: UUID
    var medicationId: UUID
    var scheduledDate: Date
    var status: String
    var recordedAt: Date
    
    init(
        id: UUID,
        medicationId: UUID,
        scheduledDate: Date,
        status: String,
        recordedAt: Date
    ) {
        self.id = id
        self.medicationId = medicationId
        self.scheduledDate = scheduledDate
        self.status = status
        self.recordedAt = recordedAt
    }
}
