//
//  MedicationDocumentTests.swift
//  FirebaseKitTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import DomainTesting
@testable import FirebaseKit
import Foundation
import Testing

struct MedicationDocumentTests {
    private let startDate = Date(timeIntervalSince1970: 1_790_000_000)

    @Test func mapsEveryMedicationField() throws {
        let medication = try makeMedication(
            name: "Magnesium",
            dosage: Dosage(amount: 2.5, unit: .ml),
            times: [(9, 0), (21, 30)],
            recurrence: .daysOfWeek([.friday, .monday]),
            startDate: startDate,
            endDate: startDate.addingTimeInterval(86_400),
            isActive: false,
            createdDate: startDate
        )

        let document = MedicationDocument(medication)

        #expect(document.name == "Magnesium")
        #expect(document.dosageAmount == 2.5)
        #expect(document.dosageUnit == "ml")
        #expect(document.times == medication.schedule.times.map {
            MedicationDocument.Time(id: $0.id.uuidString, hour: $0.hour, minute: $0.minute)
        })
        #expect(document.recurrenceKind == "daysOfWeek")
        #expect(document.recurrenceDays == [2, 6])
        #expect(document.startDate == startDate)
        #expect(document.endDate == startDate.addingTimeInterval(86_400))
        #expect(!document.isActive)
        #expect(document.createdDate == startDate)
    }

    @Test func leavesTheUpdateTimeToTheServer() throws {
        #expect(MedicationDocument(try makeMedication()).updatedAt == nil)
    }

    @Test func roundTripsThroughTheDocument() throws {
        let daily = try makeMedication(startDate: startDate, createdDate: startDate)
        let weekly = try makeMedication(
            dosage: Dosage(amount: 1, unit: .tablet),
            recurrence: .daysOfWeek([.sunday]),
            startDate: startDate,
            endDate: startDate,
            createdDate: startDate
        )

        for medication in [daily, weekly] {
            #expect(try MedicationDocument(medication).medication(id: medication.id.uuidString) == medication)
        }
    }

    @Test func shortensTheNameToTheRulesLimit() throws {
        let medication = try makeMedication(name: String(repeating: "a", count: 150))

        #expect(MedicationDocument(medication).name.count == MedicationDocument.nameLimit)
    }

    @Test func roundTripsPhotoNotesAndStock() throws {
        let medication = try makeMedication(
            startDate: startDate,
            createdDate: startDate,
            photo: Data([1, 2, 3]),
            notes: "With food",
            stock: 12.5
        )

        let document = MedicationDocument(medication)

        #expect(document.photo == Data([1, 2, 3]))
        #expect(document.notes == "With food")
        #expect(document.stock == 12.5)
        #expect(try document.medication(id: medication.id.uuidString) == medication)
    }

    @Test func dropsAPhotoLargerThanTheRulesAllow() throws {
        let photo = Data(count: MedicationDocument.photoLimit + 1)
        let medication = try makeMedication(photo: photo)

        #expect(MedicationDocument(medication).photo == nil)
    }

    @Test func shortensTheNotesToTheLimit() throws {
        let medication = try makeMedication(notes: String(repeating: "a", count: 500))

        #expect(MedicationDocument(medication).notes?.count == MedicationDocument.notesLimit)
    }

    @Test func rejectsDocumentIdThatIsNotAnIdentifier() throws {
        let document = MedicationDocument(try makeMedication())

        #expect(throws: FirestoreDocumentError.invalidIdentifier("not-a-uuid")) {
            try document.medication(id: "not-a-uuid")
        }
    }

    @Test func rejectsUnknownCodes() throws {
        let unit = makeDocument(dosageUnit: "spoon")
        let recurrence = makeDocument(recurrenceKind: "monthly")

        #expect(throws: FirestoreDocumentError.unknownDosageUnit("spoon")) {
            try unit.medication(id: UUID().uuidString)
        }
        #expect(throws: FirestoreDocumentError.unknownRecurrence("monthly")) {
            try recurrence.medication(id: UUID().uuidString)
        }
    }

    @Test func rejectsTimeOutsideTheDay() {
        let document = makeDocument(times: [MedicationDocument.Time(id: UUID().uuidString, hour: 24, minute: 0)])

        #expect(throws: DomainError.invalidTime) {
            try document.medication(id: UUID().uuidString)
        }
    }

    private func makeDocument(
        dosageUnit: String = "mg",
        times: [MedicationDocument.Time] = [MedicationDocument.Time(id: UUID().uuidString, hour: 9, minute: 0)],
        recurrenceKind: String = "daily"
    ) -> MedicationDocument {
        MedicationDocument(
            name: "Vitamin D",
            dosageAmount: 10,
            dosageUnit: dosageUnit,
            times: times,
            recurrenceKind: recurrenceKind,
            recurrenceDays: [],
            startDate: startDate,
            endDate: nil,
            isActive: true,
            createdDate: startDate,
            photo: nil,
            notes: nil,
            stock: nil
        )
    }
}
