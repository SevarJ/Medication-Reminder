//
//  ScheduledDose.swift
//  Domain
//
//  Created by Sevar Jafarli on 16.09.26.
//

import Foundation

public struct ScheduledDose: Identifiable, Sendable {
    public let medication: Medication
    public let scheduledDate: Date
    public let log: DoseLog?
    
    public var id: ID {
        ID(
            medicationId: medication.id,
            scheduledDate: scheduledDate
        )
    }
    
    public init(
        medication: Medication,
        scheduledDate: Date,
        log: DoseLog? = nil
    ) {
        self.medication = medication
        self.scheduledDate = scheduledDate
        self.log = log
    }
    
    public func state(at now: Date) -> DoseState {
         if let status = log?.status {
             switch status {
             case .taken:
                   return  .taken
             case .skipped:
                 return .skipped
             }
        }
        
        if scheduledDate < now {
            return .missed
        }
        else {
            return .pending
        }
    }
    
    public struct ID: Hashable, Sendable {
        let medicationId: UUID
        let scheduledDate: Date
    }
}

public enum DoseState: Sendable, Equatable {
    case pending
    case missed
    case skipped
    case taken
}
