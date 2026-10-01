//
//  FirestoreUserProfileRepository.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseFirestore

struct FirestoreUserProfileRepository: UserProfileRepository {
    func save(_ account: UserAccount) async throws {
        var data: [String: Any] = UserProfileDocument.fields(for: account)
        data[UserProfileDocument.updatedAtField] = FieldValue.serverTimestamp()

        try await Firestore.firestore()
            .collection(UserProfileDocument.collection)
            .document(account.id)
            .setData(data)
    }
}
