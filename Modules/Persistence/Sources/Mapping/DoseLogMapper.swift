//
//  DoseLogMapper.swift
//  Persistence
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain

enum DoseLogMapper {
    static func toEntity(_ log: DoseLog) -> DoseLogEntity {
        DoseLogEntity(
            id: log.id,
            medicationId: log.medicationId,
            scheduledDate: log.scheduledDate,
            status: statusCode(log.status),
            recordedAt: log.recordedAt
        )
    }

    static func apply(_ log: DoseLog, to entity: DoseLogEntity) {
        entity.medicationId = log.medicationId
        entity.scheduledDate = log.scheduledDate
        entity.status = statusCode(log.status)
        entity.recordedAt = log.recordedAt
    }

    static func toDomain(_ entity: DoseLogEntity) throws -> DoseLog {
        DoseLog(
            id: entity.id,
            medicationId: entity.medicationId,
            scheduledDate: entity.scheduledDate,
            status: try status(from: entity.status),
            recordedAt: entity.recordedAt
        )
    }

    private static func statusCode(_ status: DoseStatus) -> String {
        switch status {
        case .taken: "taken"
        case .skipped: "skipped"
        }
    }

    private static func status(from code: String) throws -> DoseStatus {
        switch code {
        case "taken": .taken
        case "skipped": .skipped
        default: throw PersistenceError.unknownDoseStatus(code)
        }
    }
}
