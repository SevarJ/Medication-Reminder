//
//  DoseLogDocumentTests.swift
//  FirebaseKitTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
@testable import FirebaseKit
import Foundation
import Testing

struct DoseLogDocumentTests {
    private let scheduledDate = Date(timeIntervalSince1970: 1_790_000_000)

    private func makeLog(status: DoseStatus = .taken) -> DoseLog {
        DoseLog(
            medicationId: UUID(),
            scheduledDate: scheduledDate,
            status: status,
            recordedAt: scheduledDate.addingTimeInterval(120)
        )
    }

    @Test func mapsEveryLogField() {
        let log = makeLog(status: .skipped)

        let document = DoseLogDocument(log)

        #expect(document.medicationId == log.medicationId.uuidString)
        #expect(document.scheduledDate == scheduledDate)
        #expect(document.status == "skipped")
        #expect(document.recordedAt == scheduledDate.addingTimeInterval(120))
        #expect(document.updatedAt == nil)
    }

    @Test func roundTripsThroughTheDocument() throws {
        for log in [makeLog(status: .taken), makeLog(status: .skipped)] {
            #expect(try DoseLogDocument(log).doseLog(id: log.id.uuidString) == log)
        }
    }

    @Test func queriesUseTheStoredFieldNames() {
        #expect(DoseLogDocument.CodingKeys.medicationId.stringValue == "medicationId")
        #expect(DoseLogDocument.CodingKeys.scheduledDate.stringValue == "scheduledDate")
    }

    @Test func rejectsIdentifiersThatAreNotUUIDs() {
        let document = DoseLogDocument(makeLog())
        let orphan = DoseLogDocument(
            medicationId: "missing",
            scheduledDate: scheduledDate,
            status: "taken",
            recordedAt: scheduledDate
        )

        #expect(throws: FirestoreDocumentError.invalidIdentifier("not-a-uuid")) {
            try document.doseLog(id: "not-a-uuid")
        }
        #expect(throws: FirestoreDocumentError.invalidIdentifier("missing")) {
            try orphan.doseLog(id: UUID().uuidString)
        }
    }

    @Test func rejectsUnknownStatus() {
        let document = DoseLogDocument(
            medicationId: UUID().uuidString,
            scheduledDate: scheduledDate,
            status: "postponed",
            recordedAt: scheduledDate
        )

        #expect(throws: FirestoreDocumentError.unknownDoseStatus("postponed")) {
            try document.doseLog(id: UUID().uuidString)
        }
    }
}
