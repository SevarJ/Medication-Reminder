//
//  L10n.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

enum L10n {
    enum Common {
        static var ok: String {
            String(localized: "common.ok", defaultValue: "OK", bundle: .module)
        }
        
        static var cancel: String {
            String(localized: "common.cancel", defaultValue: "Cancel", bundle: .module)
        }
        
        static var save: String {
            String(localized: "common.save", defaultValue: "Save", bundle: .module)
        }
        
        static var tryAgain: String {
            String(localized: "common.tryAgain", defaultValue: "Try Again", bundle: .module)
        }
        
        static var errorTitle: String {
            String(localized: "common.error.title", defaultValue: "Something Went Wrong", bundle: .module)
        }
    }
    
    enum List {
        static var title: String {
            String(localized: "list.title", defaultValue: "Medications", bundle: .module)
        }
        
        static var allMedications: String {
            String(localized: "list.section.all", defaultValue: "All Medications", bundle: .module)
        }
        
        static var emptyTitle: String {
            String(localized: "list.empty.title", defaultValue: "No Medications Yet", bundle: .module)
        }
        
        static var emptyMessage: String {
            String(localized: "list.empty.message", defaultValue: "Add your first medication to start receiving reminders.", bundle: .module)
        }
        
        static var loadFailedTitle: String {
            String(localized: "list.failure.title", defaultValue: "Could Not Load Medications", bundle: .module)
        }
        
        static var paused: String {
            String(localized: "list.row.paused", defaultValue: "Paused", bundle: .module)
        }
        
        static var pauseReminders: String {
            String(localized: "list.action.pause", defaultValue: "Pause Reminders", bundle: .module)
        }
        
        static var resumeReminders: String {
            String(localized: "list.action.resume", defaultValue: "Resume Reminders", bundle: .module)
        }
    }
    
    enum Banner {
        static var title: String {
            String(localized: "banner.title", defaultValue: "Notifications Are Off", bundle: .module)
        }
        
        static var requestMessage: String {
            String(localized: "banner.message.request", defaultValue: "Turn on notifications so your reminders arrive on time.", bundle: .module)
        }
        
        static var settingsMessage: String {
            String(localized: "banner.message.settings", defaultValue: "Reminders cannot be delivered until notifications are enabled in Settings.", bundle: .module)
        }
        
        static var turnOn: String {
            String(localized: "banner.action.turnOn", defaultValue: "Turn On Notifications", bundle: .module)
        }
        
        static var openSettings: String {
            String(localized: "banner.action.openSettings", defaultValue: "Open Settings", bundle: .module)
        }
    }
    
    enum Editor {
        static var newTitle: String {
            String(localized: "editor.title.new", defaultValue: "New Medication", bundle: .module)
        }
        
        static var editTitle: String {
            String(localized: "editor.title.edit", defaultValue: "Edit Medication", bundle: .module)
        }
        
        static var invalidInputTitle: String {
            String(localized: "editor.error.title", defaultValue: "Check Your Input", bundle: .module)
        }
        
        static var details: String {
            String(localized: "editor.section.details", defaultValue: "Details", bundle: .module)
        }
        
        static var namePlaceholder: String {
            String(localized: "editor.field.name", defaultValue: "Medication name", bundle: .module)
        }
        
        static var dosage: String {
            String(localized: "editor.field.dosage", defaultValue: "Dosage", bundle: .module)
        }
        
        static var amount: String {
            String(localized: "editor.field.amount", defaultValue: "Amount", bundle: .module)
        }
        
        static var unit: String {
            String(localized: "editor.field.unit", defaultValue: "Unit", bundle: .module)
        }
        
        static var repeatSection: String {
            String(localized: "editor.section.repeat", defaultValue: "Repeat", bundle: .module)
        }
        
        static var everyDay: String {
            String(localized: "editor.repeat.everyDay", defaultValue: "Every Day", bundle: .module)
        }
        
        static var specificDays: String {
            String(localized: "editor.repeat.specificDays", defaultValue: "Specific Days", bundle: .module)
        }
        
        static var duration: String {
            String(localized: "editor.section.duration", defaultValue: "Duration", bundle: .module)
        }
        
        static var starts: String {
            String(localized: "editor.field.starts", defaultValue: "Starts", bundle: .module)
        }
        
        static var endDate: String {
            String(localized: "editor.field.endDate", defaultValue: "End Date", bundle: .module)
        }
        
        static var ends: String {
            String(localized: "editor.field.ends", defaultValue: "Ends", bundle: .module)
        }
        
        static var reminders: String {
            String(localized: "editor.section.reminders", defaultValue: "Reminders", bundle: .module)
        }
        
        static var addTime: String {
            String(localized: "editor.action.addTime", defaultValue: "Add Time", bundle: .module)
        }
        
        static var status: String {
            String(localized: "editor.section.status", defaultValue: "Status", bundle: .module)
        }
        
        static var remindersEnabled: String {
            String(localized: "editor.field.remindersEnabled", defaultValue: "Reminders Enabled", bundle: .module)
        }
        
        static var deleteMedication: String {
            String(localized: "editor.action.delete", defaultValue: "Delete Medication", bundle: .module)
        }
    }
    
    enum Schedule {
        static var everyDay: String {
            String(localized: "schedule.everyDay", defaultValue: "Every day", bundle: .module)
        }
        
        static var noDaysSelected: String {
            String(localized: "schedule.noDays", defaultValue: "No days selected", bundle: .module)
        }
    }
    
    enum Today {
        static var title: String {
            String(localized: "today.title", defaultValue: "Today", bundle: .module)
        }
        
        static var emptyTitle: String {
            String(localized: "today.empty.title", defaultValue: "Nothing Scheduled Today", bundle: .module)
        }
        
        static var emptyMessage: String {
            String(localized: "today.empty.message", defaultValue: "Medications scheduled for today will appear here.", bundle: .module)
        }
        
        static var loadFailedTitle: String {
            String(localized: "today.failure.title", defaultValue: "Could Not Load Today", bundle: .module)
        }
        
        static var morning: String {
            String(localized: "today.period.morning", defaultValue: "Morning", bundle: .module)
        }
        
        static var afternoon: String {
            String(localized: "today.period.afternoon", defaultValue: "Afternoon", bundle: .module)
        }
        
        static var evening: String {
            String(localized: "today.period.evening", defaultValue: "Evening", bundle: .module)
        }
        
        static var skip: String {
            String(localized: "today.dose.skip", defaultValue: "Skip", bundle: .module)
        }
        
        static var skipped: String {
            String(localized: "today.dose.skipped", defaultValue: "Skipped", bundle: .module)
        }
        
        static var missed: String {
            String(localized: "today.dose.missed", defaultValue: "Missed", bundle: .module)
        }
        
        static var markTaken: String {
            String(localized: "today.dose.markTaken", defaultValue: "Mark as taken", bundle: .module)
        }
        
        static var markNotTaken: String {
            String(localized: "today.dose.markNotTaken", defaultValue: "Mark as not taken", bundle: .module)
        }
        
        static func takenAt(_ time: String) -> String {
            String(localized: "today.dose.takenAt", defaultValue: "Taken \(time)", bundle: .module)
        }
    }
    
    enum History {
        static var title: String {
            String(localized: "history.title", defaultValue: "History", bundle: .module)
        }
        
        static var lastSevenDays: String {
            String(localized: "history.adherence.title", defaultValue: "Last 7 Days", bundle: .module)
        }
        
        static var emptyTitle: String {
            String(localized: "history.empty.title", defaultValue: "No History Yet", bundle: .module)
        }
        
        static var emptyMessage: String {
            String(localized: "history.empty.message", defaultValue: "Doses from the last seven days will appear here.", bundle: .module)
        }
        
        static var loadFailedTitle: String {
            String(localized: "history.failure.title", defaultValue: "Could Not Load History", bundle: .module)
        }
    }
    
    enum Priming {
        static var title: String {
            String(localized: "priming.title", defaultValue: "Never Miss a Dose", bundle: .module)
        }
        
        static var message: String {
            String(localized: "priming.message", defaultValue: "MedReminder uses notifications to remind you when it's time to take your medication. You can mark doses as taken or snooze them right from the notification.", bundle: .module)
        }
        
        static var allow: String {
            String(localized: "priming.action.allow", defaultValue: "Allow Notifications", bundle: .module)
        }
        
        static var notNow: String {
            String(localized: "priming.action.notNow", defaultValue: "Not Now", bundle: .module)
        }
    }
    
    enum Error {
        static var nameEmpty: String {
            String(localized: "error.nameEmpty", defaultValue: "Enter a medication name.", bundle: .module)
        }
        
        static var timeUnselected: String {
            String(localized: "error.timeUnselected", defaultValue: "Add at least one reminder time.", bundle: .module)
        }
        
        static var invalidTime: String {
            String(localized: "error.invalidTime", defaultValue: "Choose a valid reminder time.", bundle: .module)
        }
        
        static var duplicateTime: String {
            String(localized: "error.duplicateTime", defaultValue: "Reminder times must be different from each other.", bundle: .module)
        }
        
        static var weekdayUnselected: String {
            String(localized: "error.weekdayUnselected", defaultValue: "Select at least one day of the week.", bundle: .module)
        }
        
        static var invalidDateRange: String {
            String(localized: "error.invalidDateRange", defaultValue: "The end date cannot be earlier than the start date.", bundle: .module)
        }
        
        static var doseOutsideEditableRange: String {
            String(localized: "error.doseOutsideEditableRange", defaultValue: "Doses can only be updated within the last 7 days.", bundle: .module)
        }
        
        static var medicationNotFound: String {
            String(localized: "error.medicationNotFound", defaultValue: "This medication no longer exists.", bundle: .module)
        }
        
        static var notificationsOff: String {
            String(localized: "error.notificationsOff", defaultValue: "Notifications are turned off, so reminders were not scheduled.", bundle: .module)
        }
        
        static var invalidAmount: String {
            String(localized: "error.invalidAmount", defaultValue: "Enter a dosage amount greater than zero.", bundle: .module)
        }
        
        static var generic: String {
            String(localized: "error.generic", defaultValue: "Something went wrong. Please try again.", bundle: .module)
        }
    }
}
