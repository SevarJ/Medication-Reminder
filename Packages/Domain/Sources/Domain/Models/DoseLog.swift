//
//  DoseLog.swift
//  Domain
//
//  Created by Sevar Jafarli on 16.09.26.
//

import Foundation

public struct DoseLog: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let medicationId: UUID
    public let scheduledDate: Date
    public let status: DoseStatus
    public let recordedAt: Date
    
    public init(
        id: UUID = UUID(),
        medicationId: UUID,
        scheduledDate: Date,
        status: DoseStatus,
        recordedAt: Date
    ) {
        self.id = id
        self.medicationId = medicationId
        self.scheduledDate = scheduledDate
        self.status = status
        self.recordedAt = recordedAt
    }
}
