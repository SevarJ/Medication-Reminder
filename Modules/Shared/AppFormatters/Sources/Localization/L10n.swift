//
//  L10n.swift
//  AppFormatters
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import Foundation

enum L10n {
    enum Dosage {
        static func milligrams(_ amount: String) -> String {
            String(localized: "dosage.milligrams", defaultValue: "\(amount) mg", bundle: .module.localized())
        }
        
        static func milliliters(_ amount: String) -> String {
            String(localized: "dosage.milliliters", defaultValue: "\(amount) ml", bundle: .module.localized())
        }
        
        static func tabletsFraction(_ amount: String) -> String {
            String(localized: "dosage.tablets.fraction", defaultValue: "\(amount) tablets", bundle: .module.localized())
        }
        
        static func dropsFraction(_ amount: String) -> String {
            String(localized: "dosage.drops.fraction", defaultValue: "\(amount) drops", bundle: .module.localized())
        }
        
        static func tablets(_ count: Int) -> String {
            String(localized: "dosage.tablets", defaultValue: "\(count) tablets", bundle: .module.localized())
        }
        
        static func drops(_ count: Int) -> String {
            String(localized: "dosage.drops", defaultValue: "\(count) drops", bundle: .module.localized())
        }
    }
    
    enum Unit {
        static var milligram: String {
            String(localized: "unit.milligram", defaultValue: "mg", bundle: .module.localized())
        }
        
        static var milliliter: String {
            String(localized: "unit.milliliter", defaultValue: "ml", bundle: .module.localized())
        }
        
        static var tablet: String {
            String(localized: "unit.tablet", defaultValue: "tablet", bundle: .module.localized())
        }
        
        static var drop: String {
            String(localized: "unit.drop", defaultValue: "drop", bundle: .module.localized())
        }
    }
    
    enum Error {
        static var nameEmpty: String {
            String(localized: "error.nameEmpty", defaultValue: "Enter a medication name.", bundle: .module.localized())
        }
        
        static var timeUnselected: String {
            String(localized: "error.timeUnselected", defaultValue: "Add at least one reminder time.", bundle: .module.localized())
        }
        
        static var invalidTime: String {
            String(localized: "error.invalidTime", defaultValue: "Choose a valid reminder time.", bundle: .module.localized())
        }
        
        static var duplicateTime: String {
            String(localized: "error.duplicateTime", defaultValue: "Reminder times must be different from each other.", bundle: .module.localized())
        }
        
        static var weekdayUnselected: String {
            String(localized: "error.weekdayUnselected", defaultValue: "Select at least one day of the week.", bundle: .module.localized())
        }
        
        static var invalidDateRange: String {
            String(localized: "error.invalidDateRange", defaultValue: "The end date cannot be earlier than the start date.", bundle: .module.localized())
        }
        
        static var doseOutsideEditableRange: String {
            String(localized: "error.doseOutsideEditableRange", defaultValue: "Doses can only be updated within the last 7 days.", bundle: .module.localized())
        }
        
        static var medicationNotFound: String {
            String(localized: "error.medicationNotFound", defaultValue: "This medication no longer exists.", bundle: .module.localized())
        }
        
        static var notificationsOff: String {
            String(localized: "error.notificationsOff", defaultValue: "Notifications are turned off, so reminders were not scheduled.", bundle: .module.localized())
        }
        
        static var generic: String {
            String(localized: "error.generic", defaultValue: "Something went wrong. Please try again.", bundle: .module.localized())
        }
    }
}
