//
//  ErrorFormatter.swift
//  AppFormatters
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Domain

public enum ErrorFormatter {
    public static func message(for error: Error) -> String {
        if let domainError = error as? DomainError {
            switch domainError {
            case .nameEmpty:
                return L10n.Error.nameEmpty
            case .timeUnselected:
                return L10n.Error.timeUnselected
            case .invalidTime:
                return L10n.Error.invalidTime
            case .duplicateTime:
                return L10n.Error.duplicateTime
            case .weekdayUnselected:
                return L10n.Error.weekdayUnselected
            case .invalidDateRange:
                return L10n.Error.invalidDateRange
            case .doseOutsideEditableRange:
                return L10n.Error.doseOutsideEditableRange
            case .medicationNotFound:
                return L10n.Error.medicationNotFound
            }
        }
        
        if error is ReminderError {
            return L10n.Error.notificationsOff
        }
        
        return L10n.Error.generic
    }
}
