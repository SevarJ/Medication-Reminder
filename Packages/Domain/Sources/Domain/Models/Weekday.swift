//
//  Weekday.swift
//  Domain
//
//  Created by Sevar Jafarli on 12.09.26.
//

public enum Weekday: Int, CaseIterable, Sendable, Comparable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    public var order: Int {
        (rawValue + 5) % 7
    }
    
    public static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.order < rhs.order
    }
}
