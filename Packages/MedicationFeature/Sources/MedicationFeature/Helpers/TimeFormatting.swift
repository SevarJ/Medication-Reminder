//
//  TimeFormatting.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 12.09.26.
//

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
    
    var hourAndMinute: (hour: Int, minute: Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0, components.minute ?? 0)
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
