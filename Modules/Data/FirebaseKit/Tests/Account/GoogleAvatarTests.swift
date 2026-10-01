//
//  GoogleAvatarTests.swift
//  FirebaseKitTests
//
//  Created by Sevar Jafarli on 01.10.26.
//

@testable import FirebaseKit
import Foundation
import Testing

struct GoogleAvatarTests {
    @Test func asksGoogleForALargerPhoto() throws {
        let url = try #require(URL(string: "https://lh3.googleusercontent.com/a/photo=s96-c"))

        #expect(GoogleAvatar.enlarged(url).absoluteString == "https://lh3.googleusercontent.com/a/photo=s400-c")
    }

    @Test func leavesOtherAddressesAlone() throws {
        let unsized = try #require(URL(string: "https://lh3.googleusercontent.com/a/photo"))
        let elsewhere = try #require(URL(string: "https://example.com/avatar=s96-c"))

        #expect(GoogleAvatar.enlarged(unsized) == unsized)
        #expect(GoogleAvatar.enlarged(elsewhere) == elsewhere)
    }
}
