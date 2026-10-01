//
//  AccountCollections.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseAuth
internal import FirebaseFirestore

/// Everything an account owns sits under its `users/{uid}` document.
/// The user and the database are looked up on every call, never stored, so a sign-out or a cleared database is picked up at once.
enum AccountCollections {
    static func medications() throws -> CollectionReference {
        try userDocument().collection(MedicationDocument.collection)
    }

    static func doseLogs() throws -> CollectionReference {
        try userDocument().collection(DoseLogDocument.collection)
    }

    private static func userDocument() throws -> DocumentReference {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AccountError.notSignedIn
        }

        return Firestore.firestore().collection(UserProfileDocument.collection).document(userId)
    }
}
