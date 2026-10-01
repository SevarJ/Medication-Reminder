//
//  FirebaseFactory.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain

enum FirebaseFactory {
    static func makeAuthenticator() -> any AccountAuthenticating {
        FirebaseAccountAuthenticator()
    }

    static func makeProfileRepository() -> any UserProfileRepository {
        FirestoreUserProfileRepository()
    }
}
