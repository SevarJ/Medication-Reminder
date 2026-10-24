//
//  ErrorFormatterTests.swift
//  AppFormattersTests
//
//  Created by Sevar Jafarli on 26.09.26.
//

import AppFormatters
import Domain
import DomainTesting
import Testing

struct ErrorFormatterTests {
    @Test func describesDomainErrors() {
        #expect(ErrorFormatter.message(for: DomainError.nameEmpty) == "Enter a medication name.")
        #expect(ErrorFormatter.message(for: DomainError.medicationNotFound) == "This medication no longer exists.")
    }

    @Test func explainsMissingNotificationAccess() {
        #expect(ErrorFormatter.message(for: ReminderError.authorizationDenied) == "Notifications are turned off, so reminders were not scheduled.")
    }

    @Test func explainsAMissingConnection() {
        #expect(ErrorFormatter.message(for: ConnectionError.offline) == "No internet connection. Connect and try again.")
    }

    @Test func describesAccountErrors() {
        #expect(ErrorFormatter.message(for: AccountError.signInFailed) == "Couldn't sign in with Google. Please try again.")
        #expect(ErrorFormatter.message(for: AccountError.notSignedIn) == "You're signed out. Please sign in again.")
    }

    @Test func fallsBackToGenericMessage() {
        #expect(ErrorFormatter.message(for: PersistenceFailure()) == "Something went wrong. Please try again.")
    }
}
