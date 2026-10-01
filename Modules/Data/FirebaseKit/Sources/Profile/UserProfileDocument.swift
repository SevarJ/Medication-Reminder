//
//  UserProfileDocument.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain

/// The `users/{uid}` document. Field names and limits mirror `firestore.rules`, which rejects anything else.
enum UserProfileDocument {
    static let collection = "users"
    static let updatedAtField = "updatedAt"

    static let displayNameLimit = 100
    static let photoURLLimit = 2048

    static func fields(for account: UserAccount) -> [String: String] {
        var fields: [String: String] = [:]

        if let displayName = account.displayName, !displayName.isEmpty {
            fields["displayName"] = String(displayName.prefix(displayNameLimit))
        }

        if let email = account.email, !email.isEmpty {
            fields["email"] = email
        }

        if let photoURL = account.photoURL?.absoluteString, photoURL.hasPrefix("https://"), photoURL.count <= photoURLLimit {
            fields["photoURL"] = photoURL
        }

        return fields
    }
}
