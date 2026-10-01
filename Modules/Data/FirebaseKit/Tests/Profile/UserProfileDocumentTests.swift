//
//  UserProfileDocumentTests.swift
//  FirebaseKitTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

import Domain
import DomainTesting
@testable import FirebaseKit
import Foundation
import Testing

struct UserProfileDocumentTests {
    @Test func mapsEveryAccountField() throws {
        let photoURL = try #require(URL(string: "https://example.com/avatar.png"))
        let account = makeUserAccount(displayName: "Jamie", email: "jamie.rivera@example.com", photoURL: photoURL)

        #expect(UserProfileDocument.fields(for: account) == [
            "displayName": "Jamie",
            "email": "jamie.rivera@example.com",
            "photoURL": "https://example.com/avatar.png",
        ])
    }

    @Test func leavesOutMissingAndEmptyFields() {
        let account = makeUserAccount(displayName: "", email: nil, photoURL: nil)

        #expect(UserProfileDocument.fields(for: account).isEmpty)
    }

    @Test func leavesOutPhotoURLTheRulesWouldReject() throws {
        let insecure = try #require(URL(string: "http://example.com/avatar.png"))
        let account = makeUserAccount(photoURL: insecure)

        #expect(UserProfileDocument.fields(for: account)["photoURL"] == nil)
    }

    @Test func shortensDisplayNameToTheRulesLimit() {
        let account = makeUserAccount(displayName: String(repeating: "a", count: 150))

        #expect(UserProfileDocument.fields(for: account)["displayName"]?.count == UserProfileDocument.displayNameLimit)
    }
}
