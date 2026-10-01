//
//  DoseLogDocument.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseFirestore
import Foundation

/// A `users/{uid}/doseLogs/{logId}` document, with the log's id as the document id.
/// Field names and codes mirror `firestore.rules`, which rejects anything else.
struct DoseLogDocument: Codable {
    static let collection = "doseLogs"

    enum CodingKeys: String, CodingKey {
        case medicationId
        case scheduledDate
        case status
        case recordedAt
        case updatedAt
    }

    let medicationId: String
    let scheduledDate: Date
    let status: String
    let recordedAt: Date
    /// Left empty on every write, which makes the server fill in its own time.
    @ServerTimestamp private(set) var updatedAt: Date? = nil
}

extension DoseLogDocument {
    init(_ log: DoseLog) {
        self.init(
            medicationId: log.medicationId.uuidString,
            scheduledDate: log.scheduledDate,
            status: Self.statusCode(log.status),
            recordedAt: log.recordedAt
        )
    }

    func doseLog(id documentId: String) throws -> DoseLog {
        guard let id = UUID(uuidString: documentId) else {
            throw FirestoreDocumentError.invalidIdentifier(documentId)
        }

        guard let medicationId = UUID(uuidString: medicationId) else {
            throw FirestoreDocumentError.invalidIdentifier(medicationId)
        }

        return DoseLog(
            id: id,
            medicationId: medicationId,
            scheduledDate: scheduledDate,
            status: try doseStatus(),
            recordedAt: recordedAt
        )
    }

    private func doseStatus() throws -> DoseStatus {
        switch status {
        case "taken": .taken
        case "skipped": .skipped
        default: throw FirestoreDocumentError.unknownDoseStatus(status)
        }
    }

    private static func statusCode(_ status: DoseStatus) -> String {
        switch status {
        case .taken: "taken"
        case .skipped: "skipped"
        }
    }
}
