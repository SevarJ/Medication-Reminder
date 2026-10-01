//
//  FirestoreDoseLogStore.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseFirestore
import Foundation

struct FirestoreDoseLogStore: DoseLogRemoteStore {
    /// The most writes Firestore accepts in one batch.
    private static let batchLimit = 500

    /// Asks the server only, so an offline device gets an error instead of a partial offline copy.
    /// Writes that are still queued on this device are part of the result.
    func fetch(from date: Date) async throws -> [DoseLog] {
        let snapshot = try await AccountCollections.doseLogs()
            .whereField(DoseLogDocument.CodingKeys.scheduledDate.stringValue, isGreaterThanOrEqualTo: date)
            .getDocuments(source: .server)

        return try snapshot.documents.map { document in
            try document.data(as: DoseLogDocument.self).doseLog(id: document.documentID)
        }
    }

    func save(_ log: DoseLog) async throws {
        try AccountCollections.doseLogs()
            .document(log.id.uuidString)
            .setData(from: DoseLogDocument(log))
    }

    func delete(id: UUID) async throws {
        try AccountCollections.doseLogs()
            .document(id.uuidString)
            .queueDelete()
    }

    /// The device caches only recent logs, so the full list has to be looked up before it can be deleted.
    /// Offline the lookup answers from Firestore's own copy, and logs it has never read stay on the server.
    func deleteAll(medicationId: UUID) async throws {
        let logs = try AccountCollections.doseLogs()
        let documents = try await logs
            .whereField(DoseLogDocument.CodingKeys.medicationId.stringValue, isEqualTo: medicationId.uuidString)
            .getDocuments()
            .documents

        for start in stride(from: 0, to: documents.count, by: Self.batchLimit) {
            let batch = logs.firestore.batch()

            for document in documents[start..<min(start + Self.batchLimit, documents.count)] {
                batch.deleteDocument(document.reference)
            }

            batch.queueCommit()
        }
    }
}
