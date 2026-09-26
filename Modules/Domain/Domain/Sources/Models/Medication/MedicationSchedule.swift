//
//  MedicationSchedule.swift
//  Domain
//
//  Created by Sevar Jafarli on 12.09.26.
//

import Foundation

public struct MedicationSchedule: Sendable, Equatable, Hashable {
    public let times: [MedTime]
    public let recurrence: Recurrence
    public let startDate: Date
    public let endDate: Date?
    
    public init(
        times: [MedTime],
        recurrence: Recurrence = .daily,
        startDate: Date,
        endDate: Date? = nil
    ) {
        self.times = times
        self.recurrence = recurrence
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public func isWithinDateRange(on date: Date, calendar: Calendar = .current) -> Bool {
        let day = calendar.startOfDay(for: date)
        
        guard day >= calendar.startOfDay(for: startDate) else { return false }
        
        if let endDate, day > calendar.startOfDay(for: endDate) { return false }
        
        return true
    }
    
    public func occurs(on date: Date, calendar: Calendar = .current) -> Bool {
        guard isWithinDateRange(on: date, calendar: calendar) else { return false }
        
        guard let weekday = Weekday(rawValue: calendar.component(.weekday, from: date)) else {
            return false
        }
        
        return recurrence.includes(weekday)
    }
    
    public func doses(on date: Date, calendar: Calendar = .current) -> [Date] {
        guard occurs(on: date, calendar: calendar) else { return [] }
        
        let day = calendar.startOfDay(for: date)
        
        return times.sorted().compactMap { time in
            calendar.date(
                bySettingHour: time.hour,
                minute: time.minute,
                second: 0,
                of: day
            )
        }
    }
}
