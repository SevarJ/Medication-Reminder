//
//  Recurrence.swift
//  Domain
//
//  Created by Sevar Jafarli on 12.09.26.
//

public enum Recurrence: Sendable, Equatable, Hashable {
    case daily
    case daysOfWeek(Set<Weekday>)
    
    public var weekdays: Set<Weekday> {
        switch self {
        case .daily:
            Set(Weekday.allCases)
        case .daysOfWeek(let days):
            days
        }
    }
    
    public func includes(_ weekday: Weekday) -> Bool {
        weekdays.contains(weekday)
    }
}
