//
//  FirestoreMedicationStore.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseFirestore
import Foundation

struct FirestoreMedicationStore: MedicationRemoteStore {
    /// Asks the server only, so an offline device gets an error instead of a partial offline copy.
    /// Writes that are still queued on this device are part of the result.
    func fetchAll() async throws -> [Medication] {
        let snapshot = try await AccountCollections.medications().getDocuments(source: .server)

        return try snapshot.documents.map { document in
            try document.data(as: MedicationDocument.self).medication(id: document.documentID)
        }
    }

    func save(_ medication: Medication) async throws {
        try AccountCollections.medications()
            .document(medication.id.uuidString)
            .setData(from: MedicationDocument(medication))
    }

    func delete(id: UUID) async throws {
        try AccountCollections.medications()
            .document(id.uuidString)
            .queueDelete()
    }
}
