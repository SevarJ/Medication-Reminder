//
//  L10n.swift
//  AccountImpl
//
//  Created by Sevar Jafarli on 01.10.26.
//

import AppLocalization
import Foundation

enum L10n {
    enum SignIn {
        static var title: String {
            String(localized: "signIn.title", defaultValue: "Welcome to MedReminder", bundle: .module.localized())
        }

        static var message: String {
            String(localized: "signIn.message", defaultValue: "Sign in with your Google account to start tracking your medications.", bundle: .module.localized())
        }

        static var continueWithGoogle: String {
            String(localized: "signIn.action.google", defaultValue: "Continue with Google", bundle: .module.localized())
        }
    }
}
