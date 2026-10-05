//
//  DayOutcome.swift
//  Domain
//
//  Created by Sevar Jafarli on 05.10.26.
//

import Foundation

public enum DayOutcome: Sendable, Equatable {
    /// Nothing was scheduled.
    case none
    /// Every dose is still ahead.
    case upcoming
    /// Every dose was taken.
    case complete
    /// Some doses were taken. A day still in progress lands here too.
    case partial
    /// No dose was taken and at least one is behind.
    case missed
}

public extension DoseDaySummary {
    func outcome(at now: Date) -> DayOutcome {
        if doses.isEmpty {
            return .none
        }
        
        if takenCount == doses.count {
            return .complete
        }
        
        if takenCount > 0 {
            return .partial
        }
        
        return doses.allSatisfy { $0.state(at: now) == .pending } ? .upcoming : .missed
    }
}
