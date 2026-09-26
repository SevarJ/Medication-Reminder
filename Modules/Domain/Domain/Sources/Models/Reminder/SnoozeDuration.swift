//
//  SnoozeDuration.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public enum SnoozeDuration: Int, CaseIterable, Identifiable, Sendable {
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    
    public static let `default`: SnoozeDuration = .tenMinutes
    
    public init(minutes: Int?) {
        self = minutes.flatMap(SnoozeDuration.init(rawValue:)) ?? .default
    }
    
    public var id: Int { rawValue }
    
    public var minutes: Int { rawValue }
    
    public var interval: TimeInterval {
        TimeInterval(rawValue * 60)
    }
}
