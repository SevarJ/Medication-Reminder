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
            times: medication.schedule.times.map(record),
            recurrenceKind: recurrenceKind(medication.schedule.recurrence),
            recurrenceDays: recurrenceDays(medication.schedule.recurrence),
            startDate: medication.schedule.startDate,
            endDate: medication.schedule.endDate,
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
        entity.times = medication.schedule.times.map(record)
        entity.recurrenceKind = recurrenceKind(medication.schedule.recurrence)
        entity.recurrenceDays = recurrenceDays(medication.schedule.recurrence)
        entity.startDate = medication.schedule.startDate
        entity.endDate = medication.schedule.endDate
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
            schedule: MedicationSchedule(
                times: times,
                recurrence: try recurrence(from: entity),
                startDate: entity.startDate,
                endDate: entity.endDate
            ),
            isActive: entity.isActive,
            createdDate: entity.createdDate
        )
    }

    private static func recurrenceKind(_ recurrence: Recurrence) -> String {
        switch recurrence {
        case .daily: "daily"
        case .daysOfWeek: "daysOfWeek"
        }
    }
    
    private static func recurrenceDays(_ recurrence: Recurrence) -> [Int] {
        switch recurrence {
        case .daily: []
        case .daysOfWeek(let days): days.map { $0.rawValue }.sorted()
        }
    }
    
    private static func recurrence(from entity: MedicationEntity) throws -> Recurrence {
        switch entity.recurrenceKind {
        case "daily":
            return .daily
        case "daysOfWeek":
            return .daysOfWeek(Set(entity.recurrenceDays.compactMap(Weekday.init(rawValue:))))
        default:
            throw PersistenceError.unknownRecurrence(entity.recurrenceKind)
        }
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
