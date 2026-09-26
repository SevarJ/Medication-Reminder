//
//  TimeFormatting.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppLocalization
import Domain
import Foundation

extension Date {
    static func at(hour: Int, minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: .now
        ) ?? .now
    }
    
    var timeText: String {
        let value = hourAndMinute
        return String(format: "%02d:%02d", value.hour, value.minute)
    }
    
    var hourAndMinute: (hour: Int, minute: Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0, components.minute ?? 0)
    }
}

extension Calendar {
    static var localized: Calendar {
        var calendar = Calendar.current
        calendar.locale = AppLanguage.current.locale
        return calendar
    }
}

extension MedTime {
    var displayText: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    var date: Date {
        .at(hour: hour, minute: minute)
    }
}

extension Weekday {
    var shortSymbol: String {
        let calendar = Calendar.localized
        let symbol = calendar.veryShortWeekdaySymbols[rawValue - 1]
        
        return symbol.allSatisfy(\.isNumber) ? calendar.shortStandaloneWeekdaySymbols[rawValue - 1] : symbol
    }
}

extension Recurrence {
    var displayText: String {
        switch self {
        case .daily:
            return L10n.Schedule.everyDay
        case .daysOfWeek(let days):
            guard !days.isEmpty else { return L10n.Schedule.noDaysSelected }
            return days.sorted().map { Calendar.localized.shortWeekdaySymbols[$0.rawValue - 1] }.joined(separator: ", ")
        }
    }
}
