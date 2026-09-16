//
//  ErrorText.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain

func message(for error: Error) -> String {
    if let domainError = error as? DomainError {
        switch domainError {
        case .nameEmpty:
            return "Enter a medication name."
        case .timeUnselected:
            return "Add at least one reminder time."
        case .invalidTime:
            return "Choose a valid reminder time."
        case .duplicateTime:
            return "Reminder times must be different from each other."
        case .weekdayUnselected:
            return "Select at least one day of the week."
        case .invalidDateRange:
            return "The end date cannot be earlier than the start date."
        case .medicationNotFound:
            return "This medication no longer exists."
        }
    }
    
    if error is ReminderError {
        return "Notifications are turned off, so reminders were not scheduled."
    }
    
    return "Something went wrong. Please try again."
}
