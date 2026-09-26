//
//  L10n.swift
//  SettingsImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import Foundation

enum L10n {
    enum Settings {
        static var title: String {
            String(localized: "settings.title", defaultValue: "Settings", bundle: .module.localized())
        }
        
        static var general: String {
            String(localized: "settings.section.general", defaultValue: "General", bundle: .module.localized())
        }
        
        static var language: String {
            String(localized: "settings.language", defaultValue: "Language", bundle: .module.localized())
        }
        
        static var systemLanguage: String {
            String(localized: "settings.language.system", defaultValue: "System", bundle: .module.localized())
        }
        
        static var appearance: String {
            String(localized: "settings.appearance", defaultValue: "Appearance", bundle: .module.localized())
        }
        
        static var appearanceSystem: String {
            String(localized: "settings.appearance.system", defaultValue: "System", bundle: .module.localized())
        }
        
        static var appearanceLight: String {
            String(localized: "settings.appearance.light", defaultValue: "Light", bundle: .module.localized())
        }
        
        static var appearanceDark: String {
            String(localized: "settings.appearance.dark", defaultValue: "Dark", bundle: .module.localized())
        }
        
        static var notifications: String {
            String(localized: "settings.section.notifications", defaultValue: "Notifications", bundle: .module.localized())
        }
        
        static var reminders: String {
            String(localized: "settings.notifications.reminders", defaultValue: "Reminders", bundle: .module.localized())
        }
        
        static var notificationsOn: String {
            String(localized: "settings.notifications.on", defaultValue: "On", bundle: .module.localized())
        }
        
        static var notificationsOff: String {
            String(localized: "settings.notifications.off", defaultValue: "Off", bundle: .module.localized())
        }
        
        static var notificationsNotSetUp: String {
            String(localized: "settings.notifications.notSetUp", defaultValue: "Not Set Up", bundle: .module.localized())
        }
        
        static var snooze: String {
            String(localized: "settings.snooze", defaultValue: "Snooze For", bundle: .module.localized())
        }
        
        static func snoozeOption(minutes: Int) -> String {
            String(localized: "settings.snooze.option", defaultValue: "\(minutes) min", bundle: .module.localized())
        }
        
        static var about: String {
            String(localized: "settings.section.about", defaultValue: "About", bundle: .module.localized())
        }
        
        static var version: String {
            String(localized: "settings.version", defaultValue: "Version", bundle: .module.localized())
        }
    }
}
