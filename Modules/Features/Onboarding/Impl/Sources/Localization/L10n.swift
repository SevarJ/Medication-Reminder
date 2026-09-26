//
//  L10n.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import Foundation

enum L10n {
    enum Priming {
        static var title: String {
            String(localized: "priming.title", defaultValue: "Never Miss a Dose", bundle: .module.localized())
        }
        
        static var message: String {
            String(localized: "priming.message", defaultValue: "MedReminder uses notifications to remind you when it's time to take your medication. You can mark doses as taken or snooze them right from the notification.", bundle: .module.localized())
        }
        
        static var allow: String {
            String(localized: "priming.action.allow", defaultValue: "Allow Notifications", bundle: .module.localized())
        }
        
        static var notNow: String {
            String(localized: "priming.action.notNow", defaultValue: "Not Now", bundle: .module.localized())
        }
    }
}
