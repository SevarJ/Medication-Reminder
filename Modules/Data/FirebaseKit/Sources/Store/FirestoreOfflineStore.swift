//
//  FirestoreOfflineStore.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseFirestore

struct FirestoreOfflineStore: RemoteOfflineStore {
    /// Persistence can only be cleared on a terminated instance. The next `Firestore.firestore()` call makes a fresh one.
    func clear() async throws {
        let firestore = Firestore.firestore()

        try await firestore.terminate()
        try await firestore.clearPersistence()
    }
}
