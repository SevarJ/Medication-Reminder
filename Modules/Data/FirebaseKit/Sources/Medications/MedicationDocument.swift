//
//  MedicationDocument.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseFirestore
import Foundation

/// A `users/{uid}/medications/{medicationId}` document, with the medication's id as the document id.
/// Field names and codes mirror `firestore.rules`, which rejects anything else.
struct MedicationDocument: Codable {
    static let collection = "medications"
    /// The rules allow three times as much, which covers characters that take several bytes.
    static let nameLimit = 100
    static let notesLimit = Medication.notesLimit
    /// The rules refuse a larger photo, and the app shrinks photos far below this.
    static let photoLimit = 100_000

    struct Time: Codable, Equatable {
        let id: String
        let hour: Int
        let minute: Int
    }

    let name: String
    let dosageAmount: Double
    let dosageUnit: String
    let times: [Time]
    let recurrenceKind: String
    let recurrenceDays: [Int]
    let startDate: Date
    let endDate: Date?
    let isActive: Bool
    let createdDate: Date
    let photo: Data?
    let notes: String?
    let stock: Double?
    /// Left empty on every write, which makes the server fill in its own time.
    @ServerTimestamp private(set) var updatedAt: Date? = nil
}

extension MedicationDocument {
    init(_ medication: Medication) {
        let schedule = medication.schedule

        self.init(
            name: String(medication.name.prefix(Self.nameLimit)),
            dosageAmount: medication.dosage.amount,
            dosageUnit: Self.unitCode(medication.dosage.unit),
            times: schedule.times.map { Time(id: $0.id.uuidString, hour: $0.hour, minute: $0.minute) },
            recurrenceKind: Self.recurrenceKind(schedule.recurrence),
            recurrenceDays: Self.recurrenceDays(schedule.recurrence),
            startDate: schedule.startDate,
            endDate: schedule.endDate,
            isActive: medication.isActive,
            createdDate: medication.createdDate,
            photo: medication.photo.flatMap { $0.count <= Self.photoLimit ? $0 : nil },
            notes: medication.notes.map { String($0.prefix(Self.notesLimit)) },
            stock: medication.stock
        )
    }

    func medication(id documentId: String) throws -> Medication {
        guard let id = UUID(uuidString: documentId) else {
            throw FirestoreDocumentError.invalidIdentifier(documentId)
        }

        return Medication(
            id: id,
            name: name,
            dosage: Dosage(amount: dosageAmount, unit: try dosageUnit(from: dosageUnit)),
            schedule: MedicationSchedule(
                times: try times.map(medTime),
                recurrence: try recurrence(),
                startDate: startDate,
                endDate: endDate
            ),
            isActive: isActive,
            createdDate: createdDate,
            photo: photo,
            notes: notes,
            stock: stock
        )
    }

    private func medTime(_ time: Time) throws -> MedTime {
        guard let id = UUID(uuidString: time.id) else {
            throw FirestoreDocumentError.invalidIdentifier(time.id)
        }

        return try MedTime(id: id, hour: time.hour, minute: time.minute)
    }

    private func recurrence() throws -> Recurrence {
        switch recurrenceKind {
        case "daily":
            return .daily
        case "daysOfWeek":
            return .daysOfWeek(Set(recurrenceDays.compactMap(Weekday.init(rawValue:))))
        default:
            throw FirestoreDocumentError.unknownRecurrence(recurrenceKind)
        }
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

    private static func unitCode(_ unit: DosageUnit) -> String {
        switch unit {
        case .mg: "mg"
        case .ml: "ml"
        case .tablet: "tablet"
        case .drop: "drop"
        }
    }

    private func dosageUnit(from code: String) throws -> DosageUnit {
        switch code {
        case "mg": .mg
        case "ml": .ml
        case "tablet": .tablet
        case "drop": .drop
        default: throw FirestoreDocumentError.unknownDosageUnit(code)
        }
    }
}
