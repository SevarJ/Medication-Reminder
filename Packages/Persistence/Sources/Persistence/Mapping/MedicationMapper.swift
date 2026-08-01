//
//  MedicationMapper.swift
//  Persistence
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Domain

enum MedicationMapper {
    static func toEntity(_ medication: Medication) -> MedicationEntity {
        MedicationEntity(
            id: medication.id,
            name: medication.name,
            dosageAmount: medication.dosage.amount,
            dosageUnit: unitCode(medication.dosage.unit),
            times: medication.times.map(record),
            isActive: medication.isActive,
            createdDate: medication.createdDate
        )
    }

    static func apply(
        _ medication: Medication,
        to entity: MedicationEntity
    ) {
        entity.name = medication.name
        entity.dosageAmount = medication.dosage.amount
        entity.dosageUnit = unitCode(medication.dosage.unit)
        entity.times = medication.times.map(record)
        entity.isActive = medication.isActive
    }

    static func toDomain(_ entity: MedicationEntity) throws -> Medication {
        let unit = try dosageUnit(from: entity.dosageUnit)
        let times = try entity.times.map {
            try MedTime(id: $0.id, hour: $0.hour, minute: $0.minute)
        }

        return Medication(
            id: entity.id,
            name: entity.name,
            dosage: Dosage(amount: entity.dosageAmount, unit: unit),
            times: times,
            isActive: entity.isActive,
            createdDate: entity.createdDate
        )
    }

    private static func record(_ medTime: MedTime) -> MedTimeRecord {
        MedTimeRecord(
            id: medTime.id,
            hour: medTime.hour,
            minute: medTime.minute
        )
    }

    private static func unitCode(_ unit: DosageUnit) -> String {
        switch unit {
        case .mg: "mg"
        case .ml: "ml"
        case .tablet: "tablet"
        case .drop: "drop"
        }
    }

    private static func dosageUnit(from code: String) throws -> DosageUnit {
        switch code {
        case "mg": .mg
        case "ml": .ml
        case "tablet": .tablet
        case "drop": .drop
        default: throw PersistenceError.unknownDosageUnit(code)
        }
    }
}
