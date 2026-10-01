//
//  UserAccountFactory.swift
//  DomainTesting
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import Foundation

public func makeUserAccount(
    id: String = "user-1",
    displayName: String? = "Jamie Rivera",
    email: String? = "jamie.rivera@example.com",
    photoURL: URL? = nil
) -> UserAccount {
    UserAccount(id: id, displayName: displayName, email: email, photoURL: photoURL)
}
