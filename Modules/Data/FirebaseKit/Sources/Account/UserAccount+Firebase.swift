//
//  UserAccount+Firebase.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
internal import FirebaseAuth

extension UserAccount {
    init(user: User) {
        self.init(
            id: user.uid,
            displayName: user.displayName,
            email: user.email,
            photoURL: user.photoURL.map(GoogleAvatar.enlarged)
        )
    }
}
