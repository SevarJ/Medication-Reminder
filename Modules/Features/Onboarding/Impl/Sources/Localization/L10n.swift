//
//  L10n.swift
//  OnboardingImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import Foundation

enum L10n {
    enum Introduction {
        static var remindersTitle: String {
            String(localized: "introduction.reminders.title", defaultValue: "On-Time Reminders", bundle: .module.localized())
        }
        
        static var remindersMessage: String {
            String(localized: "introduction.reminders.message", defaultValue: "You get a notification when it's time for a dose.", bundle: .module.localized())
        }
        
        static var todayTitle: String {
            String(localized: "introduction.today.title", defaultValue: "Your Day at a Glance", bundle: .module.localized())
        }
        
        static var todayMessage: String {
            String(localized: "introduction.today.message", defaultValue: "See what you've taken today and what's left.", bundle: .module.localized())
        }
        
        static var stockTitle: String {
            String(localized: "introduction.stock.title", defaultValue: "Never Run Out", bundle: .module.localized())
        }
        
        static var stockMessage: String {
            String(localized: "introduction.stock.message", defaultValue: "We'll tell you 3 days before a box runs out.", bundle: .module.localized())
        }
        
        static var next: String {
            String(localized: "introduction.action.next", defaultValue: "Continue", bundle: .module.localized())
        }
        
        static var start: String {
            String(localized: "introduction.action.start", defaultValue: "Get Started", bundle: .module.localized())
        }
    }
    
    enum Priming {
        static var title: String {
            String(localized: "priming.title", defaultValue: "Never Miss a Dose", bundle: .module.localized())
        }
        
        static var message: String {
            String(localized: "priming.message", defaultValue: "We'll let you know when it's time.", bundle: .module.localized())
        }
        
        static var allow: String {
            String(localized: "priming.action.allow", defaultValue: "Allow Notifications", bundle: .module.localized())
        }
        
        static var notNow: String {
            String(localized: "priming.action.notNow", defaultValue: "Not Now", bundle: .module.localized())
        }
        
        static var sampleTime: String {
            String(localized: "priming.sample.time", defaultValue: "now", bundle: .module.localized())
        }
        
        static var sampleTitle: String {
            String(localized: "priming.sample.title", defaultValue: "Vitamin D", bundle: .module.localized())
        }
        
        static var sampleBody: String {
            String(localized: "priming.sample.body", defaultValue: "1 tablet · After meals", bundle: .module.localized())
        }
    }
}
