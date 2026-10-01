//
//  UserAccount.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Foundation

public struct UserAccount: Equatable, Identifiable, Sendable {
    public let id: String
    public let displayName: String?
    public let email: String?
    public let photoURL: URL?

    public init(id: String, displayName: String? = nil, email: String? = nil, photoURL: URL? = nil) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
    }
}
