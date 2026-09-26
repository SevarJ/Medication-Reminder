//
//  L10n.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation

enum L10n {
    enum Common {
        static var ok: String {
            String(localized: "common.ok", defaultValue: "OK", bundle: .module.localized())
        }
        
        static var cancel: String {
            String(localized: "common.cancel", defaultValue: "Cancel", bundle: .module.localized())
        }
        
        static var save: String {
            String(localized: "common.save", defaultValue: "Save", bundle: .module.localized())
        }
        
        static var tryAgain: String {
            String(localized: "common.tryAgain", defaultValue: "Try Again", bundle: .module.localized())
        }
        
        static var delete: String {
            String(localized: "common.delete", defaultValue: "Delete", bundle: .module.localized())
        }
        
        static var errorTitle: String {
            String(localized: "common.error.title", defaultValue: "Something Went Wrong", bundle: .module.localized())
        }
    }
    
    enum List {
        static var title: String {
            String(localized: "list.title", defaultValue: "Medications", bundle: .module.localized())
        }
        
        static var allMedications: String {
            String(localized: "list.section.all", defaultValue: "All Medications", bundle: .module.localized())
        }
        
        static var emptyTitle: String {
            String(localized: "list.empty.title", defaultValue: "No Medications Yet", bundle: .module.localized())
        }
        
        static var emptyMessage: String {
            String(localized: "list.empty.message", defaultValue: "Add your first medication to start receiving reminders.", bundle: .module.localized())
        }
        
        static var loadFailedTitle: String {
            String(localized: "list.failure.title", defaultValue: "Could Not Load Medications", bundle: .module.localized())
        }
        
        static var paused: String {
            String(localized: "list.row.paused", defaultValue: "Paused", bundle: .module.localized())
        }
        
        static var pauseReminders: String {
            String(localized: "list.action.pause", defaultValue: "Pause Reminders", bundle: .module.localized())
        }
        
        static func deleteTitle(_ name: String) -> String {
            String(localized: "list.delete.title", defaultValue: "Delete \(name)?", bundle: .module.localized())
        }
        
        static var deleteMessage: String {
            String(localized: "list.delete.message", defaultValue: "Its reminders and dose history will be removed. This can't be undone.", bundle: .module.localized())
        }
        
        static var resumeReminders: String {
            String(localized: "list.action.resume", defaultValue: "Resume Reminders", bundle: .module.localized())
        }
    }
    
    enum Banner {
        static var title: String {
            String(localized: "banner.title", defaultValue: "Notifications Are Off", bundle: .module.localized())
        }
        
        static var requestMessage: String {
            String(localized: "banner.message.request", defaultValue: "Turn on notifications so your reminders arrive on time.", bundle: .module.localized())
        }
        
        static var settingsMessage: String {
            String(localized: "banner.message.settings", defaultValue: "Reminders cannot be delivered until notifications are enabled in Settings.", bundle: .module.localized())
        }
        
        static var turnOn: String {
            String(localized: "banner.action.turnOn", defaultValue: "Turn On Notifications", bundle: .module.localized())
        }
        
        static var openSettings: String {
            String(localized: "banner.action.openSettings", defaultValue: "Open Settings", bundle: .module.localized())
        }
    }
    
    enum Editor {
        static var newTitle: String {
            String(localized: "editor.title.new", defaultValue: "New Medication", bundle: .module.localized())
        }
        
        static var editTitle: String {
            String(localized: "editor.title.edit", defaultValue: "Edit Medication", bundle: .module.localized())
        }
        
        static var invalidInputTitle: String {
            String(localized: "editor.error.title", defaultValue: "Check Your Input", bundle: .module.localized())
        }
        
        static var details: String {
            String(localized: "editor.section.details", defaultValue: "Details", bundle: .module.localized())
        }
        
        static var namePlaceholder: String {
            String(localized: "editor.field.name", defaultValue: "Medication name", bundle: .module.localized())
        }
        
        static var dosage: String {
            String(localized: "editor.field.dosage", defaultValue: "Dosage", bundle: .module.localized())
        }
        
        static var amount: String {
            String(localized: "editor.field.amount", defaultValue: "Amount", bundle: .module.localized())
        }
        
        static var unit: String {
            String(localized: "editor.field.unit", defaultValue: "Unit", bundle: .module.localized())
        }
        
        static var repeatSection: String {
            String(localized: "editor.section.repeat", defaultValue: "Repeat", bundle: .module.localized())
        }
        
        static var everyDay: String {
            String(localized: "editor.repeat.everyDay", defaultValue: "Every Day", bundle: .module.localized())
        }
        
        static var specificDays: String {
            String(localized: "editor.repeat.specificDays", defaultValue: "Specific Days", bundle: .module.localized())
        }
        
        static var duration: String {
            String(localized: "editor.section.duration", defaultValue: "Duration", bundle: .module.localized())
        }
        
        static var starts: String {
            String(localized: "editor.field.starts", defaultValue: "Starts", bundle: .module.localized())
        }
        
        static var endDate: String {
            String(localized: "editor.field.endDate", defaultValue: "End Date", bundle: .module.localized())
        }
        
        static var ends: String {
            String(localized: "editor.field.ends", defaultValue: "Ends", bundle: .module.localized())
        }
        
        static var reminders: String {
            String(localized: "editor.section.reminders", defaultValue: "Reminders", bundle: .module.localized())
        }
        
        static var addTime: String {
            String(localized: "editor.action.addTime", defaultValue: "Add Time", bundle: .module.localized())
        }
        
        static var status: String {
            String(localized: "editor.section.status", defaultValue: "Status", bundle: .module.localized())
        }
        
        static var remindersEnabled: String {
            String(localized: "editor.field.remindersEnabled", defaultValue: "Reminders Enabled", bundle: .module.localized())
        }
        
        static var deleteMedication: String {
            String(localized: "editor.action.delete", defaultValue: "Delete Medication", bundle: .module.localized())
        }
    }
    
    enum Schedule {
        static var everyDay: String {
            String(localized: "schedule.everyDay", defaultValue: "Every day", bundle: .module.localized())
        }
        
        static var noDaysSelected: String {
            String(localized: "schedule.noDays", defaultValue: "No days selected", bundle: .module.localized())
        }
    }
    
    enum Today {
        static var title: String {
            String(localized: "today.title", defaultValue: "Today", bundle: .module.localized())
        }
        
        static var emptyTitle: String {
            String(localized: "today.empty.title", defaultValue: "Nothing Scheduled Today", bundle: .module.localized())
        }
        
        static var emptyMessage: String {
            String(localized: "today.empty.message", defaultValue: "Medications scheduled for today will appear here.", bundle: .module.localized())
        }
        
        static var loadFailedTitle: String {
            String(localized: "today.failure.title", defaultValue: "Could Not Load Today", bundle: .module.localized())
        }
        
        static var morning: String {
            String(localized: "today.period.morning", defaultValue: "Morning", bundle: .module.localized())
        }
        
        static var afternoon: String {
            String(localized: "today.period.afternoon", defaultValue: "Afternoon", bundle: .module.localized())
        }
        
        static var evening: String {
            String(localized: "today.period.evening", defaultValue: "Evening", bundle: .module.localized())
        }
        
        static var skip: String {
            String(localized: "today.dose.skip", defaultValue: "Skip", bundle: .module.localized())
        }
        
        static var skipped: String {
            String(localized: "today.dose.skipped", defaultValue: "Skipped", bundle: .module.localized())
        }
        
        static var missed: String {
            String(localized: "today.dose.missed", defaultValue: "Missed", bundle: .module.localized())
        }
        
        static var markTaken: String {
            String(localized: "today.dose.markTaken", defaultValue: "Mark as taken", bundle: .module.localized())
        }
        
        static var markNotTaken: String {
            String(localized: "today.dose.markNotTaken", defaultValue: "Mark as not taken", bundle: .module.localized())
        }
        
        static var emptyDayTitle: String {
            String(localized: "today.empty.dayTitle", defaultValue: "Nothing Scheduled", bundle: .module.localized())
        }
        
        static var taken: String {
            String(localized: "today.progress.taken", defaultValue: "taken", bundle: .module.localized())
        }
        
        static func weekAdherence(_ percent: String) -> String {
            String(localized: "today.progress.week", defaultValue: "Last 7 days: \(percent)", bundle: .module.localized())
        }
        
        static var nextDose: String {
            String(localized: "today.next.title", defaultValue: "Next dose", bundle: .module.localized())
        }
        
        static var takeNow: String {
            String(localized: "today.next.takeNow", defaultValue: "Take Now", bundle: .module.localized())
        }
        
        static var allDone: String {
            String(localized: "today.allDone", defaultValue: "All of today's doses are taken", bundle: .module.localized())
        }
        
        static var take: String {
            String(localized: "today.dose.take", defaultValue: "Take", bundle: .module.localized())
        }
        
        static func takenAt(_ time: String) -> String {
            String(localized: "today.dose.takenAt", defaultValue: "Taken \(time)", bundle: .module.localized())
        }
    }
    
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
    
    enum Reminder {
        static var close: String {
            String(localized: "reminder.close", defaultValue: "Close", bundle: .module.localized())
        }
        
        static var eyebrow: String {
            String(localized: "reminder.eyebrow", defaultValue: "Time for your medication", bundle: .module.localized())
        }
        
        static var take: String {
            String(localized: "reminder.take", defaultValue: "I Took It", bundle: .module.localized())
        }
        
        static func snooze(minutes: Int) -> String {
            String(localized: "reminder.snooze", defaultValue: "Remind Me in \(minutes) Min", bundle: .module.localized())
        }
        
        static var loadFailedTitle: String {
            String(localized: "reminder.failure.title", defaultValue: "Could Not Load This Dose", bundle: .module.localized())
        }
    }
    
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
        
        static var invalidAmount: String {
            String(localized: "error.invalidAmount", defaultValue: "Enter a dosage amount greater than zero.", bundle: .module.localized())
        }
        
        static var generic: String {
            String(localized: "error.generic", defaultValue: "Something went wrong. Please try again.", bundle: .module.localized())
        }
    }
}
