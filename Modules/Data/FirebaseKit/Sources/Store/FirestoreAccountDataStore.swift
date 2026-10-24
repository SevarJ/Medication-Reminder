//
//  FirestoreAccountDataStore.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Domain
internal import FirebaseFirestore

struct FirestoreAccountDataStore: AccountDataRemoteStore {
    private static let batchLimit = 500

    func deleteAll() async throws {
        try await Self.deleteDocuments(in: AccountCollections.doseLogs())
        try await Self.deleteDocuments(in: AccountCollections.medications())
        try await AccountCollections.userDocument().delete()
    }

    private static func deleteDocuments(in collection: CollectionReference) async throws {
        let documents = try await collection.getDocuments(source: .server).documents

        for start in stride(from: 0, to: documents.count, by: batchLimit) {
            let batch = collection.firestore.batch()

            for document in documents[start..<min(start + batchLimit, documents.count)] {
                batch.deleteDocument(document.reference)
            }

            try await batch.commit()
        }
    }
}
