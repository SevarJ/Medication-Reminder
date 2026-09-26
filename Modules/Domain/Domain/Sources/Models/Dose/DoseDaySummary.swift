//
//  DoseDaySummary.swift
//  Domain
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Foundation

public struct DoseDaySummary: Identifiable, Equatable, Sendable {
    public let date: Date
    public let doses: [ScheduledDose]
    
    public init(date: Date, doses: [ScheduledDose]) {
        self.date = date
        self.doses = doses
    }
    
    public var id: Date { date }
    
    public var takenCount: Int {
        doses.count { $0.log?.status == .taken }
    }
    
    public var adherence: Double {
        guard !doses.isEmpty else { return 0 }
        
        return Double(takenCount) / Double(doses.count)
    }
}
